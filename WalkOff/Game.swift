//
//  Game.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit
import GameKit

protocol GameDelegate: class {
	
    func game(
		scoreUpdatedForPlayer playerID: String,
		previousRank: Int,
		newRank: Int
	)
    func game(itemUpdatedForPlayer playerID: String)
    func gamePowerUpOnStandby()
    func game(powerUpStarted standbyPowerUpIndex: Int)
    func game(challengeStartedWithID challengeID: Challenge)
    func game(chaseStartedWithID chaseID: Chase)
    func gameOffenseOnStandby()
}

class Game: NSObject {
	
	weak var delegate: GameDelegate?
    
	var gameID: String
	var gameTitle = "" //random name generator depending on total players
	
	let localPlayerID = GKLocalPlayer.localPlayer().playerID!
    var previousScore: Int
  
    var playerData = [String : Player]()
  
    var standbyPowerUpIDs = [PowerUp]()
    var offenses = [Offense]()
  
    var multiplier: Double = 1.0
    var timer = NSTimer()
	var previousActivity = ""
  
	var rankedPlayerIDs = [String]()
	var localRank = 0
	
    //initialize the game by assigning the game an ID and creating
	//a dictionary of [playerID : player]
	//sort the keys alphabetically
	init(gameData: NSDictionary) {
		self.gameID = gameData.valueForKey("id") as! String
		let playerData = gameData.objectForKey("playerData") as! NSDictionary
		previousScore = playerData[localPlayerID]!.objectForKey("score") as! Int

		super.init()

		Movement.sharedInstance.addObserver(
			self,
			forKeyPath: "stepsUpdate",
			options: .New,
			context: nil
		)
		
		Movement.sharedInstance.addObserver(
			self,
			forKeyPath: "movementType",
			options: .New,
			context: nil
		)
        
		for player in playerData {
			let playerID = player.key as! String
			let playerDict = player.value as! NSDictionary
			let score = playerDict.objectForKey("score") as! Int
			
			self.playerData[playerID] = Player(score: score)
			
			if score == 0 {
				self.playerData[playerID]!.activity = "🏁"
			} else { self.playerData[playerID]!.activity = "💤" }
						
			GameManager.sharedInstance.players[playerID]!.games.append(gameID)
		}
		
		previousActivity = self.playerData[localPlayerID]!.activity
		updateRankedPlayerIDs()
		l.o.g("\(gameID) has initialized")
	}

    //begin observering the movement steps counter
    //each update calls updateScoreForLocalPlayer
	override func observeValueForKeyPath(
	keyPath: String?,
	ofObject object: AnyObject?,
	change: [String : AnyObject]?,
	context: UnsafeMutablePointer<Void>) {
	
		if keyPath == "stepsUpdate" {
			let stepsUpdate = change?[NSKeyValueChangeNewKey]! as! Int
			if stepsUpdate > 0 {
					l.o.g("\(gameID) observing \(stepsUpdate) new steps")
					updateScoreForLocalPlayer(stepsUpdate)
			}
		}
	
		else if keyPath == "movementType" {
			let newActivity = change?[NSKeyValueChangeNewKey]! as! String
			if (newActivity != previousActivity) {
				playerData[localPlayerID]!.activity = newActivity
				previousActivity = newActivity
				
				GameManager.sharedInstance.emitUpdatedItem(
					gameID,
					itemType: "activity",
					itemIndex: 0,
					itemName: newActivity
				)
				delegate?.game(itemUpdatedForPlayer: localPlayerID)
            }
		}
	}
	
    //called by observer method
    func updateScoreForLocalPlayer(stepsUpdate: Int) {
        previousScore = playerData[localPlayerID]!.score!
        let scoreUpdate = Int(multiplier * Double(stepsUpdate))
        playerData[localPlayerID]!.score! += scoreUpdate
        
        updateRanking(localPlayerID)
        
        let newScore = playerData[localPlayerID]!.score!
        evaluateScoreForItem(newScore, previousScore: previousScore)
        
        GameManager.sharedInstance.emitUpdatedScore(
            gameID,
            updatedScore: newScore
        )
    }
    
    //this is called by the GameManager
	func updateScoreForOtherPlayer(playerID: String, newScore: Int) {
		playerData[playerID]!.score = newScore		
		updateRanking(playerID)
		
		l.o.g("\(gameID) score updated for \(playerID) to \(playerData[playerID]!.score!)")
	}
	
    //called by updateScoreForLocalPlayer after each update
    func evaluateScoreForItem(currentScore: Int, previousScore: Int) {
        
        if let milestone = Milestones.sharedInstance.evaluateScoreForMilestone(
        currentScore, previousScore: previousScore) {
            
            evaluateItemForID(milestone.item)
        }
    }
    
    func evaluateItemForID(item: Item) {
        
        if let powerUpID = item.powerUpID {
            print("power up")
            standbyPowerUpIDs.append(powerUpID)
            delegate?.gamePowerUpOnStandby()
        }
        
        if let powerDownID = item.powerDownID {
            print("power down")
            startPowerDown(powerDownID)
        }
        
        if let challengeID = item.challengeID {
            print("challenge")
            startChallenge(challengeID)
        }
        
        if let chaseID = item.chaseID {
            print("chase")
            startChase(chaseID)
        }
        
        if let offenseID = item.offenseID {
            print("offense")
            
        }
    }
    
    //called by detailViewController, or a challenge verification
    func startPowerUp(powerUpID: PowerUp, standbyPowerUpIndex: Int) {
        
        standbyPowerUpIDs.removeAtIndex(standbyPowerUpIndex)
        let powerUp = getPowerUp(powerUpID)
        multiplier *= powerUp.multiplier
        playerData[localPlayerID]!.powerUps.append(powerUp.name)
        let powerUpIndex = playerData[localPlayerID]!.powerUps.endIndex.predecessor()

        delegate?.game(powerUpStarted: standbyPowerUpIndex)
        delegate?.game(itemUpdatedForPlayer: localPlayerID)
        
        l.o.g("\n\(gameID) powerUp started: \(powerUp.name)")
        l.o.g("\(gameID) multiplier: \(powerUp.multiplier)")
        l.o.g("\(gameID) duration: \(powerUp.duration)")
        l.o.g("\(gameID) updated multiplier: \(multiplier)\n")

        timer = NSTimer.scheduledTimerWithTimeInterval(
            powerUp.duration,
            target: self,
            selector: "stopPowerUp:",
            userInfo: TimerInfo(item: Item(powerUpID: powerUpID), index: powerUpIndex),
            repeats: false
        )
        
        GameManager.sharedInstance.emitUpdatedItem(
            gameID,
            itemType: "powerUp",
            itemIndex: powerUpIndex,
            itemName: powerUp.name
        )
    }
    
    func stopPowerUp(timer: NSTimer) {
        
        let timerInfo = timer.userInfo as! TimerInfo
        let powerUp = getPowerUp(timerInfo.item.powerUpID!)
        
        playerData[localPlayerID]!.powerUps.removeAtIndex(timerInfo.index)
        multiplier /= powerUp.multiplier
        delegate?.game(itemUpdatedForPlayer: localPlayerID)
        
        GameManager.sharedInstance.emitUpdatedItem(
            gameID,
            itemType: "powerUp",
            itemIndex: timerInfo.index,
            itemName: ""
        )
    }
    
    func startPowerDown(powerDownID: PowerDown) {
        
        let powerDown = getPowerDown(powerDownID)
        playerData[localPlayerID]!.powerDowns.append(powerDown.name)
        let powerDownIndex = playerData[localPlayerID]!.powerDowns.endIndex.predecessor()
        multiplier /= powerDown.divider
        delegate?.game(itemUpdatedForPlayer: localPlayerID)
        
        l.o.g("\n\(gameID) powerDown started: \(powerDown.name)")
        l.o.g("\(gameID) divider: \(powerDown.divider)")
        l.o.g("\(gameID) duration: \(powerDown.duration)")
        l.o.g("\(gameID) updated multiplier: \(multiplier)\n")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(
            powerDown.duration,
            target: self,
            selector: "stopPowerDown:",
            userInfo: TimerInfo(item: Item(powerDownID: powerDownID), index: powerDownIndex),
            repeats: false
        )
        
        GameManager.sharedInstance.emitUpdatedItem(
            gameID,
            itemType: "powerDown",
            itemIndex: powerDownIndex,
            itemName: powerDown.name
        )
    }
    
    func stopPowerDown(timer: NSTimer) {
        
        let timerInfo = timer.userInfo as! TimerInfo
        let powerDown = getPowerDown(timerInfo.item.powerDownID!)
        print("INDEX \(timerInfo.index) + \(playerData[localPlayerID]!.powerDowns)")
        playerData[localPlayerID]!.powerDowns[timerInfo.index] = ""
        
        //playerData[localPlayerID]!.powerDowns.removeAtIndex(timerInfo.index)
        multiplier *= powerDown.divider
        delegate?.game(itemUpdatedForPlayer: localPlayerID)
        
        GameManager.sharedInstance.emitUpdatedItem(
            gameID,
            itemType: "powerDown",
            itemIndex: timerInfo.index,
            itemName: ""
        )
    }
	
	func startChallenge(challengeID: Challenge) {
		
        let challenge = getChallenge(challengeID)
		playerData[localPlayerID]!.challenges.append(challenge.name)
		delegate?.game(challengeStartedWithID: challengeID)
        delegate?.game(itemUpdatedForPlayer: localPlayerID)
		
		let challengeIndex = playerData[localPlayerID]!.challenges.endIndex.predecessor()
		
		GameManager.sharedInstance.emitUpdatedItem(
			gameID,
			itemType: "challenge",
			itemIndex: challengeIndex,
			itemName: challenge.name
		)

		timer = NSTimer.scheduledTimerWithTimeInterval(
			challenge.duration,
			target: self,
			selector: "stopChallenge:",
            userInfo: TimerInfo(
                item: Item(challengeID: challengeID),
                index: challengeIndex,
                previousScore: playerData[localPlayerID]!.score!),
			repeats: false
		)
	}
	
	func stopChallenge(timer: NSTimer) {
		
        let timerInfo = timer.userInfo as! TimerInfo

		//emit challenge is over
		
		playerData[localPlayerID]!.challenges.removeAtIndex(timerInfo.index)
		let challenge = getChallenge(timerInfo.item.challengeID!)
		let previousScore = timerInfo.previousScore
		let currentScore = playerData[localPlayerID]!.score!
		
		if let challengeItem = challenge.verification(previousScore: previousScore!,
        currentScore: currentScore) {
			
            evaluateItemForID(challengeItem)
		}
        
        delegate?.game(itemUpdatedForPlayer: localPlayerID)
		
		GameManager.sharedInstance.emitUpdatedItem(
			gameID,
			itemType: "challenge",
			itemIndex: timerInfo.index,
			itemName: ""
		)
	}

    func startChase(chaseID: Chase) {
        
        let chase = getChase(chaseID)
        playerData[localPlayerID]!.chases.append(chase.name)
        
        delegate?.game(chaseStartedWithID: chaseID)
        delegate?.game(itemUpdatedForPlayer: localPlayerID)
        
        let chaseIndex = playerData[localPlayerID]!.chases.endIndex.predecessor()

        GameManager.sharedInstance.emitUpdatedItem(
            gameID,
            itemType: "chase",
            itemIndex: chaseIndex,
            itemName: chase.name
        )
        
        timer = NSTimer.scheduledTimerWithTimeInterval(
            chase.duration,
            target: self,
            selector: "stopChase:",
            userInfo: TimerInfo(
                item: Item(chaseID: chaseID),
                index: chaseIndex,
                previousScore: playerData[localPlayerID]!.score!),
            repeats: false
        )
    }
    
    func stopChase(timer: NSTimer) {
        
        let timerInfo = timer.userInfo as! TimerInfo
        
        playerData[localPlayerID]!.chases.removeAtIndex(timerInfo.index)
        let chase = getChase(timerInfo.item.chaseID!)
        let previousScore = timerInfo.previousScore
        let currentScore = playerData[localPlayerID]!.score!
        
        if let chaseItem = chase.verification(previousScore: previousScore!,
        currentScore: currentScore) {
                evaluateItemForID(chaseItem)
        }
        
        GameManager.sharedInstance.emitUpdatedItem(
            gameID,
            itemType: "chase",
            itemIndex: timerInfo.index,
            itemName: ""
        )
    }
    
    func loadOffense(offenseID: Offense) {
        offenses.append(offenseID)
        
    }
    
    func fireOffense(index: Int) {
        
    }
    
	func updateItemForOtherPlayer(
    playerID: String,
    itemType: String,
    itemIndex: Int,
    itemName: String
	) {
		
		switch itemType {
			
			case "activity":
				playerData[playerID]!.activity = itemName
			
			case "powerUp":
				
				if itemName == "" {
					playerData[playerID]!.powerUps.removeAtIndex(itemIndex)
				
				} else {
					playerData[playerID]!.powerUps
						.insert(itemName, atIndex: itemIndex)
					print(playerData[localPlayerID]!.powerUps)
				}
			
			case "powerDown":
				
				if itemName == "" {
					playerData[playerID]!.powerDowns[itemIndex] = ""
					
				} else {
                    print("IAA \(itemIndex) + \(playerData[localPlayerID]!.powerDowns)")
					//playerData[playerID]!.powerDowns[itemIndex] = itemName
                    playerData[playerID]!.powerDowns.insert(itemName, atIndex: itemIndex)
				}
			
			case "challenge":
				
				if itemName == "" {
					playerData[playerID]!.challenges
						.removeAtIndex(itemIndex)
					
				} else {
					playerData[playerID]!.challenges
						.insert(itemName, atIndex: itemIndex)
				}
            
            case "chase":
                
                if itemName == "" {
                    playerData[playerID]!.chases
                        .removeAtIndex(itemIndex)
                    
                } else {
                    playerData[playerID]!.chases
                        .insert(itemName, atIndex: itemIndex)
                }
			
			default:
				print("updateItemForOtherPlayer had an error")
		}

        delegate?.game(itemUpdatedForPlayer: playerID)
	}
	
	func updateRanking(playerID: String) {
		
		let previousRank = rankedPlayerIDs.indexOf(playerID)
		updateRankedPlayerIDs()
		let newRank = rankedPlayerIDs.indexOf(playerID)
		
		delegate?.game(
			scoreUpdatedForPlayer: playerID,
			previousRank: previousRank!,
			newRank: newRank!
		)
	}
	
    func updateRankedPlayerIDs() {
		let playersToRank = playerData as NSDictionary
		let rankedPlayersArray = playersToRank.keysSortedByValueUsingComparator{
			(playerA, playerB) in
			let a = playerA as! Player
			let b = playerB as! Player
			let aScore = a.score as NSNumber!
			let bScore = b.score as NSNumber!
			return bScore.compare(aScore)
		}
		rankedPlayerIDs = rankedPlayersArray as! [String]
        //insert weapon here
		localRank = rankedPlayerIDs.indexOf(localPlayerID)! + 1
	}
	
    deinit {
    l.o.g("\(gameID) deinit Movement observer")
    Movement.sharedInstance.removeObserver(
      self,
      forKeyPath: "stepsUpdate",
      context: nil)
		Movement.sharedInstance.removeObserver(
			self,
			forKeyPath: "movementType",
			context: nil)
    }
    
    func addTestSteps() {
        updateScoreForLocalPlayer(5)

    }
}