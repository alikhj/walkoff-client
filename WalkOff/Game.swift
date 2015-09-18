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
	
	func reloadPlayerData()
}

class Game: NSObject {
	
	weak var delegate: GameDelegate?
    
	var gameID: String
	var gameTitle = "" //random name generator depending on total players
	
	let localPlayerID = GKLocalPlayer.localPlayer().playerID
  var playerData = [String : Player]()
	var previousScore: Int
  
  var isPowerUpReady = false
  var multiplier: Double = 1.0
  var timer = NSTimer()
  
	var rankedPlayerIDs = [String]()
	var localRank = 0
	var status = ""
	
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
			let score = player.value["score"] as! Int
			let status = player.value["status"] as! String
			self.playerData[playerID] = Player(score: score, status: status)
		}
		
		updateRankedPlayerIDs()
		l.o.g("\(gameID) has initialized")
	}

	override func observeValueForKeyPath(
	keyPath: String,
	ofObject object: AnyObject,
	change: [NSObject : AnyObject],
	context: UnsafeMutablePointer<Void>) {
	
		if keyPath == "stepsUpdate" {
		var stepsUpdate = change[NSKeyValueChangeNewKey]! as! Int
			if stepsUpdate > 0 {
					l.o.g("\(gameID) observing \(stepsUpdate) new steps")
					updateScoreForLocalPlayer(stepsUpdate)
			}
		}
	
		else if keyPath == "movementType" {
			var newStatus = change[NSKeyValueChangeNewKey]! as! String
			if (newStatus != status) {
				status = newStatus
				updateStatusForPlayer(localPlayerID, newStatus: status)
			}
		}
	}
	
	func updateScoreForOtherPlayer(playerID: String, newScore: Int) {
		playerData[playerID]!.score = newScore
		
		updateRanking(playerID)
		//refresh
		
		l.o.g("\(gameID) score updated for \(playerID) to \(playerData[playerID]!.score!)")
	}
	
	func updateScoreForLocalPlayer(stepsUpdate: Int) {
		previousScore = playerData[localPlayerID]!.score!
		var scoreUpdate = Int(multiplier * Double(stepsUpdate))
		playerData[localPlayerID]!.score! += scoreUpdate
		
		updateRanking(localPlayerID)
		
		var newScore = playerData[localPlayerID]!.score!
		evaluateScoreForPowerUp(newScore, previousScore: previousScore)
		
		GameManager.sharedInstance.emitUpdatedScore(
			gameID,
			updatedScore: newScore
		)
	}
	
  func evaluateScoreForPowerUp(currentScore: Int, previousScore: Int) {
		
    var milestone = Milestones.sharedInstance.evaluateScoreForMilestone(
      currentScore, previousScore: previousScore)
		
    if let _ = milestone.name {
      var powerUp = getPowerUp(milestone.powerUpID!)
      isPowerUpReady = true
			
			l.o.g("\(gameID) milestone reached: \(milestone.name)")
			l.o.g("\(gameID) powerUp available: \(milestone.powerUpID)")

      //temporary, this should be activated by a button:
      startPowerUp(milestone.powerUpID!)
    }
  }
  
  func startPowerUp(powerUpID: PowerUp) {
		
    var powerUp = getPowerUp(powerUpID)
    var powerUpInfo = [Int : String]()
    
    let powerUpRawValue = powerUpID.rawValue
    let scoreBeforePowerUp = playerData[localPlayerID]!.score!
    
    powerUpInfo[scoreBeforePowerUp] = powerUpRawValue
		
		multiplier *= powerUp.multiplier
		
		l.o.g("\(gameID) powerUp started: \(powerUp.name)")
		l.o.g("\(gameID) multiplier: \(powerUp.multiplier)")
		l.o.g("\(gameID) duration: \(powerUp.duration)")

		l.o.g("\(gameID) updated multiplier: \(multiplier)")
		
    timer = NSTimer.scheduledTimerWithTimeInterval(
      powerUp.duration,
      target: self,
      selector: "stopPowerUp:",
      userInfo: powerUpInfo,
      repeats: false
    )
  }
  
  func stopPowerUp(timer: NSTimer) {
    println("stopPowerUp")
		
		let currentScore = playerData[localPlayerID]!.score!
		let powerUpInfo = timer.userInfo as! [Int: String]
		
		for (scoreBeforePowerUp, rawValue) in powerUpInfo {
			
			let powerUpID = PowerUp(rawValue: rawValue)!
			var powerUp = getPowerUp(powerUpID)
			multiplier /= powerUp.multiplier
			
			if let verify = powerUp.verifyFunc {
				var k = verify(scoreBeforePowerUp, currentScore)
				multiplier = k.multiplier!
				println("goal achieved, granting new pUp")
				startPowerUp(k.powerUpID!)
				
			}
		}
  }
  
	func updateStatusForPlayer(playerID: String, newStatus: String) {
		playerData[playerID]?.status = newStatus
		delegate?.reloadPlayerData()
		
		if(playerID == localPlayerID) {
			GameManager.sharedInstance.emitUpdatedStatus(gameID, newStatus: newStatus)
		}
	}
	
	func updateRanking(playerID: String) {
		
		let previousRank = find(rankedPlayerIDs, playerID)
		updateRankedPlayerIDs()
		let newRank = find(rankedPlayerIDs, playerID)
		
		delegate?.game(
			scoreUpdatedForPlayer: playerID,
			previousRank: previousRank!,
			newRank: newRank!
		)
	}
	
	func updateRankedPlayerIDs() {
		var playersToRank = playerData as NSDictionary
		var rankedPlayersArray = playersToRank.keysSortedByValueUsingComparator{
			(playerA, playerB) in
			let a = playerA as! Player
			let b = playerB as! Player
			let aScore = a.score as NSNumber!
			let bScore = b.score as NSNumber!
			return bScore.compare(aScore)
		}
		rankedPlayerIDs = rankedPlayersArray as! [String]
		localRank = find(rankedPlayerIDs, localPlayerID)! + 1
		l.o.g("\(gameID) ranking updated")
	}
	
  deinit {
    l.o.g("\(gameID) deinit Movement observer")
    Movement.sharedInstance.removeObserver(
      self,
      forKeyPath: "stepsUpdate",
      context: nil)
  }

}



