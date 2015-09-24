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
  func powerDownStarted()
  func powerDownStopped()
}

class Game: NSObject {
	
	weak var delegate: GameDelegate?
    
	var gameID: String
	var gameTitle = "" //random name generator depending on total players
	
	let localPlayerID = GKLocalPlayer.localPlayer().playerID!
  var playerData = [String : Player]()
	var previousScore: Int
  
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
			let status = playerDict.objectForKey("status") as! String
			self.playerData[playerID] = Player(score: score, status: status)
			GameManager.sharedInstance.players[playerID]!.games.append(gameID)
		}
		
		previousActivity = self.playerData[localPlayerID]!.status!
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
				updateStatusForLocalPlayer(previousActivity, newActivity: newActivity)
				previousActivity = newActivity

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
		
    let milestone = Milestones.sharedInstance.evaluateScoreForMilestone(
      currentScore, previousScore: previousScore)
		
    if let _ = milestone.name {
			l.o.g("\n\(gameID) milestone : \(milestone.name!)")
			l.o.g("\(gameID) powerUp available: \(milestone.powerUpID!.rawValue)\n")
			
			let powerUp = getPowerUp(milestone.powerUpID!)
			if powerUp.multiplier == 1 {
				
			}

			
			
      standbyPowerUpIDs.append(milestone.powerUpID!)
      delegate?.powerUpOnStandby()

      //temporary, this should be activated by a button:
      //startPowerUp(milestone.powerUpID!)
    }
  }
  
  //is called by detailVC, and will be called by gameManager for powerDowns
  func startPowerUp(powerUpID: PowerUp, standbyPowerUpIndex: Int) {
		
    let powerUp = getPowerUp(powerUpID)
    var powerUpInfo = [String : AnyObject]()
		
		multiplier *= powerUp.multiplier
		
		l.o.g("\n\(gameID) powerUp started: \(powerUp.name)")
		l.o.g("\(gameID) multiplier: \(powerUp.multiplier)")
		l.o.g("\(gameID) duration: \(powerUp.duration)")
		l.o.g("\(gameID) updated multiplier: \(multiplier)\n")
		
		playerData[localPlayerID]!.status! += powerUp.name
    standbyPowerUpIDs.removeAtIndex(standbyPowerUpIndex)
    
    powerUpInfo["rawValue"] = powerUpID.rawValue
    powerUpInfo["scoreBeforeActivation"] = playerData[localPlayerID]!.score!

    timer = NSTimer.scheduledTimerWithTimeInterval(
      powerUp.duration,
      target: self,
      selector: "stopPowerUp:",
      userInfo: powerUpInfo,
      repeats: false
    )
    
		updateStatusForLocalPlayer(nil, newActivity: nil)
  }
  
  func stopPowerUp(timer: NSTimer) {
		
		let currentScore = playerData[localPlayerID]!.score!
		let powerUpInfo = timer.userInfo as! [String: AnyObject]
    
    let rawValue = powerUpInfo["rawValue"] as! String
    let scoreBeforeActivation = powerUpInfo["scoreBeforeActivation"] as! Int
    
    let powerUpID = PowerUp(rawValue: rawValue)!
    let powerUp = getPowerUp(powerUpID)
    
    let powerUpNameRange = playerData[localPlayerID]!.status!.rangeOfString(powerUp.name)
    playerData[localPlayerID]!.status!.removeRange(powerUpNameRange!)
		
    updateStatusForLocalPlayer(nil, newActivity: nil)
    
    multiplier /= powerUp.multiplier
    
    if let verify = powerUp.verify {
      let verification = verify(scoreBeforeActivation, currentScore)
      //multiplier *= verification.multiplier!
      
      l.o.g("\n\(gameID) stopping powerup: \(rawValue)\n")

      //temporary - this will fail if nil
      //startPowerUp(verification.powerUpID!)
    
    l.o.g("\n\(gameID) stopping powerup: \(rawValue)\n")

    }
  }
  
  func startPowerDown() {
    
  }
  
	func updateStatusForLocalPlayer(previousActivity: String?, newActivity: String?) {
		
		if let _ = newActivity {
			
      let startIndex = playerData[localPlayerID]!.status!.startIndex
      playerData[localPlayerID]!.status!.removeAtIndex(startIndex)
      playerData[localPlayerID]!.status!.insertContentsOf(newActivity!.characters, at: startIndex)
		}
		
		delegate?.playerDataWasUpdated()
		GameManager.sharedInstance.emitUpdatedStatus(
			gameID, newStatus: playerData[localPlayerID]!.status!)
	}
	
	func updateStatusForOtherPlayer(playerID: String, newStatus: String) {
		playerData[playerID]!.status = newStatus
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
		//l.o.g("\(gameID) ranking updated")
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