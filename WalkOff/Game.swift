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
	var rankedPlayerIDs = [String]()
	var localRank = 0
	var powerUpActive = false
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
		
		updateRanking(nil, previousRank: nil)
		l.o.g("\(gameID) has initialized")
	}

	override func observeValueForKeyPath(
	keyPath: String,
	ofObject object: AnyObject,
	change: [NSObject : AnyObject],
	context: UnsafeMutablePointer<Void>) {
	
		if keyPath == "stepsUpdate" {
		var newScoreUpdate = change[NSKeyValueChangeNewKey]! as! Int
			if newScoreUpdate > 0 {
					l.o.g("\(gameID) observing \(newScoreUpdate) new steps")
					updateScoreForPlayer(localPlayerID, scoreUpdate: newScoreUpdate)
			}
		}
	
		else if keyPath == "movementType" {
			var newStatus = change[NSKeyValueChangeNewKey]! as! String
			if (!powerUpActive && newStatus != status) {
				status = newStatus
				l.o.g("\(gameID) player is now \(status)")
				updateStatusForPlayer(localPlayerID, newStatus: status)
			}
		}
	}
	
	deinit {
		l.o.g("\(gameID) deinit Movement observer")
		Movement.sharedInstance.removeObserver(
			self,
			forKeyPath: "stepsUpdate",
			context: nil)
	}

	func updateScoreForPlayer(playerID: String, scoreUpdate: Int) {
		let previousRank = find(rankedPlayerIDs, playerID)
		
		if (playerID != localPlayerID) {
			
			playerData[playerID]?.score = scoreUpdate
			updateRanking(playerID, previousRank: previousRank!)
			
		}
		
		else if (playerID == localPlayerID) {
			
			previousScore = playerData[localPlayerID]!.score!
			println("old score: \(previousScore)")
			playerData[localPlayerID]!.score! += scoreUpdate
			
			var newScore = playerData[localPlayerID]!.score
			updateRanking(playerID, previousRank: previousRank!)
			
			GameManager.sharedInstance.emitUpdatedScore(
				gameID,
				updatedScore: newScore!
			)
		}
		
		l.o.g("\(gameID) score updated for \(playerID) to \(playerData[playerID]!.score)")
	}
  
	func updateRanking(updatedPlayerID: String?, previousRank: Int?) {
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
		
		if ((updatedPlayerID) != nil) {
			let newRank = find(rankedPlayerIDs, updatedPlayerID!)
			delegate?.game(
				scoreUpdatedForPlayer: updatedPlayerID!,
				previousRank: previousRank!,
				newRank: newRank!)
		}
		
  }
		
	func updateStatusForPlayer(playerID: String, newStatus: String) {
		playerData[playerID]?.status = newStatus
		delegate?.reloadPlayerData()
		
		if(playerID == localPlayerID) {
			GameManager.sharedInstance.emitUpdatedStatus(gameID, newStatus: newStatus)
		}
		
		delegate?.reloadPlayerData()
	}
}
