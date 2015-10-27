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
	
	func playerDataWasUpdated()
  func powerUpOnStandby()
	func powerUpStarted(standbyPowerUpIndex: Int)
	func challengeStarted(challengeID: Challenge)
	func localPlayerUpdated()
}

class Game: NSObject {
	
	weak var delegate: GameDelegate?
    
	var gameID: String
	var gameTitle = "" //random name generator depending on total players
	
	let localPlayerID = GKLocalPlayer.localPlayer().playerID!
  var previousScore: Int
  
  var playerData = [String : Player]()
  
  var standbyPowerUpIDs = [PowerUp]()
  
  var multiplier: Double = 1.0
  var timer = NSTimer()
	var previousActivity = ""
  
	var rankedPlayerIDs = [String]()
	var localRank = 0
	
	//assign the game an ID and create a dictionary of [playerID : player]
	//sort the keys alphabetically
        
	init(gameData: NSDictionary) {
		self.gameID = gameData.valueForKey("id") as! String
		let playerData = gameData.objectForKey("playerData") as! NSDictionary
		previousScore = playerData[localPlayerID]?.objectForKey("score") as! Int

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
				delegate?.playerDataWasUpdated() //change this to rowupdate
			}
		}
	}
	
	func updateScoreForOtherPlayer(playerID: String, newScore: Int) {
		playerData[playerID]!.score = newScore		
		updateRanking(playerID)
		
		l.o.g("\(gameID) score updated for \(playerID) to \(playerData[playerID]!.score!)")
	}
	
	func updateScoreForLocalPlayer(stepsUpdate: Int) {
		previousScore = playerData[localPlayerID]!.score!
		let scoreUpdate = Int(multiplier * Double(stepsUpdate))
		playerData[localPlayerID]!.score! += scoreUpdate
		
		updateRanking(localPlayerID)
		
		let newScore = playerData[localPlayerID]!.score!
		evaluateScoreForPowerUp(newScore, previousScore: previousScore)
		
		GameManager.sharedInstance.emitUpdatedScore(
			gameID,
			updatedScore: newScore
		)
	}
	
  func evaluateScoreForPowerUp(currentScore: Int, previousScore: Int) {
		
    if let milestone = Milestones.sharedInstance.evaluateScoreForMilestone(
      currentScore, previousScore: previousScore) {
				
				//change this to check for type instead of through rawValue
        if let powerUpID = PowerUp(rawValue: milestone.itemRawValue) {
          standbyPowerUpIDs.append(powerUpID)
          delegate?.powerUpOnStandby()
        }
				
        if let powerDownID = PowerDown(rawValue: milestone.itemRawValue) {
					startPowerDown(powerDownID)

        }
        
        if let challengeID = Challenge(rawValue: milestone.itemRawValue) {
          print("challenge started")
					startChallenge(challengeID)

        }
      }
  }
	
	func startChallenge(challengeID: Challenge) {
		let challenge = getChallenge(challengeID)
		var timerInfo = [String : AnyObject]()

		playerData[localPlayerID]?.challenges.append(challenge.name)
		delegate?.challengeStarted(challengeID)
		delegate?.localPlayerUpdated()
		
		let challengeIndex = playerData[localPlayerID]?.challenges.endIndex.predecessor()
		
		GameManager.sharedInstance.emitUpdatedItem(
			gameID,
			itemType: "challenge",
			itemIndex: challengeIndex!,
			itemName: challenge.name
		)

		timerInfo["rawValue"] = challengeID.rawValue
		timerInfo["previousScore"] = playerData[localPlayerID]!.score!
		timerInfo["challengeIndex"] = challengeIndex

		timer = NSTimer.scheduledTimerWithTimeInterval(
			challenge.duration,
			target: self,
			selector: "stopChallenge:",
			userInfo: timerInfo,
			repeats: false
		)
		
	}
	
	func stopChallenge(timer: NSTimer) {
		
		let timerInfo = timer.userInfo as! [String: AnyObject]
		let rawValue = timerInfo["rawValue"] as! String
		let challengeIndex = timerInfo["challengeIndex"] as! Int
		
		//emit challenge is over
		
		playerData[localPlayerID]?.challenges.removeAtIndex(challengeIndex)
		
		let challengeID = Challenge(rawValue: rawValue)
		let challenge = getChallenge(challengeID!)
		let previousScore = timerInfo["previousScore"] as! Int
		let currentScore = playerData[localPlayerID]!.score!
		
		if let item = challenge.verification(previousScore, currentScore) {
			
			if item.type == String(PowerDown.self) {
				let powerDownID = PowerDown(rawValue: item.rawValue)!
				startPowerDown(powerDownID)
			}
			
			if item.type == String(PowerUp.self) {
				let powerUpID = PowerUp(rawValue: item.rawValue)!
				standbyPowerUpIDs.append(powerUpID)
				delegate?.powerUpOnStandby()
			}
		}
		
		delegate?.playerDataWasUpdated()
		
		GameManager.sharedInstance.emitUpdatedItem(
			gameID,
			itemType: "challenge",
			itemIndex: challengeIndex,
			itemName: ""
		)

	}
	
	func startPowerDown(powerDownID: PowerDown) {
		let powerDown = getPowerDown(powerDownID)
		playerData[localPlayerID]!.powerDowns.append(powerDown.name)
		let powerDownIndex = playerData[localPlayerID]!.powerDowns.endIndex.predecessor()
		multiplier /= powerDown.divider
		delegate?.localPlayerUpdated()
		
		l.o.g("\n\(gameID) powerDown started: \(powerDown.name)")
		l.o.g("\(gameID) divider: \(powerDown.divider)")
		l.o.g("\(gameID) duration: \(powerDown.duration)")
		l.o.g("\(gameID) updated multiplier: \(multiplier)\n")
		
		var timerInfo = [String : AnyObject]()
		timerInfo["rawValue"] = powerDownID.rawValue
		timerInfo["powerDownIndex"] = powerDownIndex
		
		timer = NSTimer.scheduledTimerWithTimeInterval(
			powerDown.duration,
			target: self,
			selector: "stopPowerDown:",
			userInfo: timerInfo,
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

		let timerInfo = timer.userInfo as! [String: AnyObject]
		let rawValue = timerInfo["rawValue"] as! String
		let powerDownIndex = timerInfo["powerDownIndex"] as! Int
		
		let powerDownID = PowerDown(rawValue: rawValue)!
		let powerDown = getPowerDown(powerDownID)
		
		playerData[localPlayerID]!.powerDowns.removeAtIndex(powerDownIndex)
		multiplier *= powerDown.divider
		delegate?.localPlayerUpdated()
		
		GameManager.sharedInstance.emitUpdatedItem(
			gameID,
			itemType: "powerDown",
			itemIndex: powerDownIndex,
			itemName: ""
		)
	}
	
  func startPowerUp(powerUpID: PowerUp, standbyPowerUpIndex: Int) {
		standbyPowerUpIDs.removeAtIndex(standbyPowerUpIndex)

		let powerUp = getPowerUp(powerUpID)
		
		multiplier *= powerUp.multiplier
		playerData[localPlayerID]!.powerUps.append(powerUp.name)

		delegate?.powerUpStarted(standbyPowerUpIndex)

		let powerUpIndex = playerData[localPlayerID]!.powerUps.endIndex.predecessor()
		
		l.o.g("\n\(gameID) powerUp started: \(powerUp.name)")
		l.o.g("\(gameID) multiplier: \(powerUp.multiplier)")
		l.o.g("\(gameID) duration: \(powerUp.duration)")
		l.o.g("\(gameID) updated multiplier: \(multiplier)\n")
		
		var timerInfo = [String : AnyObject]()
    timerInfo["rawValue"] = powerUpID.rawValue
		timerInfo["powerUpIndex"] = powerUpIndex

    timer = NSTimer.scheduledTimerWithTimeInterval(
      powerUp.duration,
      target: self,
      selector: "stopPowerUp:",
      userInfo: timerInfo,
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
		let timerInfo = timer.userInfo as! [String: AnyObject]
    let rawValue = timerInfo["rawValue"] as! String
		let powerUpIndex = timerInfo["powerUpIndex"] as! Int
		
    let powerUpID = PowerUp(rawValue: rawValue)!
    let powerUp = getPowerUp(powerUpID)
    
    playerData[localPlayerID]!.powerUps.removeAtIndex(powerUpIndex)
		multiplier /= powerUp.multiplier
		
		delegate?.localPlayerUpdated()
		
		GameManager.sharedInstance.emitUpdatedItem(
			gameID,
			itemType: "powerUp",
			itemIndex: powerUpIndex,
			itemName: ""
		)
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
					playerData[playerID]!.powerDowns
						.removeAtIndex(itemIndex)
					
				} else {
					playerData[playerID]!.powerDowns
						.insert(itemName, atIndex: itemIndex)
				}
			
			case "challenge":
				
				if itemName == "" {
					playerData[playerID]!.challenges
						.removeAtIndex(itemIndex)
					
				} else {
					playerData[playerID]!.challenges
						.insert(itemName, atIndex: itemIndex)
				}
			
			default:
				print("updateItemForOtherPlayer had an error")
		}

    delegate?.playerDataWasUpdated()
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
}