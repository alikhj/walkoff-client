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
        newRank: Int)
}

class Game: NSObject {
	
    weak var delegate: GameDelegate?
    
	var gameID: String
	var gameTitle = "" //random name generator depending on total players
	
	let localPlayer = GKLocalPlayer.localPlayer()
	var allPlayers = [String : Player]()
	var rankedPlayerIDs = [String]()
	var localRank = 0
	
	//assign the game an ID and create a dictionary of [playerID : player]
	//sort the keys alphabetically

        
    init(gameData: NSDictionary) {
        self.gameID = gameData.valueForKey("id") as! String
        super.init()
        //println("gameData: \(gameData)")
        Movement.sharedInstance.addObserver(
            self,
            forKeyPath: "stepsUpdate",
            options: .New,
            context: nil)
        var players = gameData["players"] as! NSDictionary
        //println("player: \(players)")
        for player in players {
            let playerID = player.key as! String
            let playerAlias = player.value["alias"] as! String
            let score = player.value["score"] as! Int
            allPlayers[playerID] = Player(playerID: playerID, playerAlias: playerAlias)
            allPlayers[playerID]!.score = score
            
        }
        updateRanking()
        l.o.g("\(gameID) has initialized")

    }
  	
	//observe stepsUpdate variable in Movement class
	override func observeValueForKeyPath(
		keyPath: String,
		ofObject object: AnyObject,
		change: [NSObject : AnyObject],
		context: UnsafeMutablePointer<Void>) {
			if keyPath == "stepsUpdate" {
				var newScoreUpdate = change[NSKeyValueChangeNewKey]! as! Int
                if newScoreUpdate > 0 {
                    l.o.g("\(gameID) observing \(newScoreUpdate) new steps")
                    updateScoreForPlayer(localPlayer.playerID, newScore: newScoreUpdate)
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

	func updateScoreForPlayer(playerID: String, newScore: Int) {
		let previousRank = find(rankedPlayerIDs, playerID)
        if playerID != localPlayer.playerID {
			allPlayers[playerID]?.score = newScore
		} else if playerID == localPlayer.playerID {
			allPlayers[localPlayer.playerID]?.score += newScore
			var updatedScore = allPlayers[localPlayer.playerID]!.score
			GameManager.sharedInstance.emitUpdatedScore(
				gameID,
				updatedScore: updatedScore)
		}
		l.o.g("\(gameID) score updated for \(playerID) to \(allPlayers[playerID]!.score)")
        updateRanking()
        let newRank = find(rankedPlayerIDs, playerID)
        delegate?.game(
            scoreUpdatedForPlayer: playerID,
            previousRank: previousRank!,
            newRank: newRank!)
	}
	
	func updateRanking() {
		var rankablePlayers = allPlayers as NSDictionary
        println("allPlayers: \(rankablePlayers)")
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
		l.o.g("\(gameID) ranking updated")
	}
}
