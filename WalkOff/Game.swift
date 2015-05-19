//
//  Game.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit
import GameKit

class Game: NSObject {
	
	var gameID: String
	var gameTitle = "" //random name generator depending on total players
	
	let localPlayer = GKLocalPlayer.localPlayer()
	var allPlayers = [String : Player]()
	var rankedPlayerIDs = [String]()
	var localRank = 0
	
	//assign the game an ID and create a dictionary of [playerID : player]
	//sort the keys alphabetically
	init(gameID: String, allGKPlayers: [GKPlayer]) {
		self.gameID = gameID
		super.init()
		Movement.sharedInstance.addObserver(
			self,
			forKeyPath: "stepsUpdate",
			options: .New,
			context: nil)
		for player in allGKPlayers {
			allPlayers[player.playerID] = Player(gkPlayer: player)
			NSLog("\(gameID) Player \(player.playerID) has joined the game")
		}
		updateRanking()
		NSLog("\(gameID) has initialized")
	}
	
	//observe stepsUpdate variable in Movement class
	override func observeValueForKeyPath(
		keyPath: String,
		ofObject object: AnyObject,
		change: [NSObject : AnyObject],
		context: UnsafeMutablePointer<Void>) {
			if keyPath == "stepsUpdate" {
				var newScoreUpdate = change[NSKeyValueChangeNewKey]! as! Int
				NSLog("\(gameID) observing \(newScoreUpdate) new steps, emitting...")
				updateScoreForPlayer(localPlayer.playerID, newScore: newScoreUpdate)
			}
	}
	
	deinit {
		NSLog("\(gameID) Deinit Movement observer")
		Movement.sharedInstance.removeObserver(
			self,
			forKeyPath: "stepsUpdate",
			context: nil)
	}

	func updateScoreForPlayer(playerID: String, newScore: Int) {
		if playerID != localPlayer.playerID {
			allPlayers[playerID]?.score = newScore
		} else if playerID == localPlayer.playerID {
			allPlayers[localPlayer.playerID]?.score += newScore
			var updatedScore = allPlayers[localPlayer.playerID]!.score
			GameManager.sharedInstance.emitUpdatedScore(
				gameID,
				updatedScore: updatedScore)
		}
		NSLog("\(gameID) Score updated for \(playerID) to \(allPlayers[playerID]?.score)")
		//detailViewController to find old and new index to animate rank change
	}
	
	func updateRanking() {
		var rankablePlayers = allPlayers as NSDictionary
		var rankedPlayersArray = rankablePlayers.keysSortedByValueUsingComparator{
			(playerA, playerB) in
			let a = playerA as! Player
			let b = playerB as! Player
			let aScore = a.score as NSNumber
			let bScore = b.score as NSNumber
			return bScore.compare(aScore)
		}
		rankedPlayerIDs = rankedPlayersArray as! [String]
		localRank = find(rankedPlayerIDs, localPlayer.playerID)! + 1
		NSLog("\(gameID) Ranking updated")
	}
}
