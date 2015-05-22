//
//  Networking.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit
import GameKit

protocol GameManagerDelegate: class {
	func gameManager(newGameCreated gameID: String)
	func gameManager(scoreUpdatedForGame gameID: String)
}

let GameManagerSingleton = GameManager()

class GameManager: NSObject,
GameKitHelperDelegate {
	
	class var sharedInstance: GameManager {
		return GameManagerSingleton
	}
	
	let socket = SocketIOClient(socketURL: "192.241.197.7:2000")
	let localPlayer = GKLocalPlayer.localPlayer()
	
	var gameKitHelper = GameKitHelper()
	var allGames = [String : Game]()
	weak var delegate: GameManagerDelegate?
	var gameJoinedIndex = 0
	
	func startNetworking() {
		l.o.g("Networking started...")
		gameKitHelper.delegate = self
		socket.connect()
		handlers()
		//debugHandlers()
	}
	
	func gameKitHelper(newPlayersFound arrayOfPlayersFound: [GKPlayer]) {
		var allGKPlayers = arrayOfPlayersFound
		allGKPlayers.append(localPlayer)
		var playerIDs = [String]()
		for player in allGKPlayers {
			playerIDs.append(player.playerID)
		}
		playerIDs.sort{ $0 > $1 }
		l.o.g("\nJoining game with playerIDs array: \(playerIDs)")
		l.o.g("\nLocal player ID is \(localPlayer.playerID)")
		
		socket.emit("join-game",
			["playerIDs" : playerIDs,
			 "playerID"  : localPlayer.playerID ])
		
		socket.on("game-joined") {[weak self] data, ack in
			if self!.gameJoinedIndex == self!.allGames.count {
				l.o.g("\ngame-joined received, creating game")
				let received = data?[0] as? NSDictionary
				let gameID = received?.objectForKey("gameID") as! String
				var game = Game(gameID: gameID, allGKPlayers: allGKPlayers)
				self!.allGames[gameID] = game
				self!.delegate?.gameManager(newGameCreated: gameID)
				self!.gameJoinedIndex = 0
				return
			}
			self!.gameJoinedIndex++
		}
	}
	
	func emitUpdatedScore(gameID: String, updatedScore: Int) {
		socket.emit("update-score",
			[ "gameID"    : gameID,
				"playerIDs" : localPlayer.playerID,
				"newScore"  : updatedScore ])
		l.o.g("\(gameID) Sending new score as \(updatedScore)")
		delegate?.gameManager(scoreUpdatedForGame: gameID)
	}
	
	func handlers() {
		socket.on("connect") {[weak self] data, ack in
			l.o.g("Connected, with sid: \(self!.socket.sid!)")
		}
		
		socket.on("reconnect") {[weak self] data, ack in
			l.o.g("Disconnected,trying to reconnect...")
			self!.socket.connect()
		}
		
		socket.on("score-updated") {[weak self] data, ack in
			let received = data?[0] as? NSDictionary
			let gameID = received?.objectForKey("gameID") as! String
			let playerID = received?.objectForKey("playerID") as! String
			let newScore = received?.objectForKey("newScore") as! Int
			l.o.g("\n***score-update***\ngameID: \(gameID)\nplayerID: \(playerID)\nnewScore: \(newScore)")
			let game = self!.allGames[gameID]
			game?.updateScoreForPlayer(playerID, newScore: newScore)
		}
		
		socket.on("item-received") {[weak self] data, ack in
			let received = data?[0] as? NSDictionary
			let gameID = received?.objectForKey("gameID") as! String
			let playerID = received?.objectForKey("playerID") as! String
			let itemID = received?.objectForKey("itemID") as! Int
			//add more, maybe a time received?
		}
	}
	
	func debugHandlers() {
		self.socket.onAny {
			l.o.g("Got event: \($0.event), with items: \($0.items)")
		}
	}
}
