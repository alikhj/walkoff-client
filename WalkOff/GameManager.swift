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
    func gameManagerWasDisconnected()
}

let GameManagerSingleton = GameManager()

class GameManager: NSObject,
GameKitHelperDelegate {
	
	class var sharedInstance: GameManager {
		return GameManagerSingleton
	}
	
	//let socket = SocketIOClient(socketURL: "http://162.243.138.39")
    let socket = SocketIOClient(socketURL: "http://174.16.126.141:2000")

	let localPlayer = GKLocalPlayer.localPlayer()
	
	var gameKitHelper = GameKitHelper()
	var allGames = [String : Game]()
	weak var delegate: GameManagerDelegate?
    
    var allGKPlayers = [GKPlayer]()
	
	func startNetworking() {
		l.o.g("Networking started...")
		gameKitHelper.delegate = self
		socket.connect()
		handlers()
		//debugHandlers()
	}
	
	func gameKitHelper(newPlayersFound arrayOfPlayersFound: [GKPlayer]) {
        allGKPlayers = arrayOfPlayersFound
		allGKPlayers.append(localPlayer)
		var playerIDs = [String]()
        var players = [String : String]()
		for player in allGKPlayers {
			playerIDs.append(player.playerID)
            players[player.playerID] = player.alias
		}
		playerIDs.sort{ $0 > $1 }
		l.o.g("\nJoining game with playerIDs array: \(playerIDs)")
		l.o.g("\nLocal player ID is \(localPlayer.playerID)")
		
		socket.emit("join-game",
            ["players" : players,
             "playerIDs" : playerIDs,
			 "playerID"  : localPlayer.playerID,
                "alias" : localPlayer.alias,
             "count"     : playerIDs.count ])
	}
	
	func emitUpdatedScore(gameID: String, updatedScore: Int) {
		socket.emit("update-score",
			[ "gameID"    : gameID,
              "playerID" : localPlayer.playerID,
              "newScore"  : updatedScore ])
		l.o.g("\(gameID) Sending new score as \(updatedScore)")
		delegate?.gameManager(scoreUpdatedForGame: gameID)
	}
	
	func handlers() {
		socket.on("connect") {[weak self] data, ack in
			l.o.g("Connected, with sid: \(self!.socket.sid!)")
            if (self!.allGames.count > 0) {
                for gameID in self!.allGames.keys {
                    self!.socket.emit("rejoin-game",
                        ["gameID" : gameID,
                         "playerID" : self!.localPlayer.playerID])
                }
            }
            self!.socket.emit("player-connected",
                ["playerID" : self!.localPlayer.playerID,
                 "alias": self!.localPlayer.alias])
		}
    
		socket.on("reconnect") {[weak self] data, ack in
			l.o.g("Disconnected, trying to reconnect...")
            self!.delegate?.gameManagerWasDisconnected()
			self!.socket.connect()
		}
        
        
        //TO DO - check if game already existed so the delegate doesn't fire newGame
        //unneccessarily - this only works when app is restarted
        //games are duplicated if a connection is lost while app is running
        socket.on("join-games") {[weak self] data, ack in
            l.o.g("join-games received by socket...")
            println("data: \(data)")
            let currentGames = data?[0]["games"] as! NSArray
            for game in currentGames {
                var gameData = game as! NSDictionary
                var gameID = gameData.valueForKey("id") as! String
                var newGame = Game(gameData: gameData)
                self!.allGames[gameID] = newGame
                self!.delegate?.gameManager(newGameCreated: gameID)
                self!.allGKPlayers.removeAll(keepCapacity: false)
                if Movement.sharedInstance.isCountingSteps == false {
                    Movement.sharedInstance.startCountingSteps()
                }
            }
        }
        
        socket.on("player-disconnected") {[weak self] data, ack in
            let received = data?[0] as? NSDictionary
            let playerID = received?.objectForKey("playerID") as! String
            let gameID = received?.objectForKey("gameID") as! String
            l.o.g("\n\(playerID) was disconnected from \(gameID)")
        }
        
        socket.on("player-reconnected") {[weak self] data, ack in
            let received = data?[0] as? NSDictionary
            let playerID = received?.objectForKey("playerID") as! String
            let gameID = received?.objectForKey("gameID") as! String
            l.o.g("\n\(playerID) has reconnected and joined \(gameID)")
            let lastScoreUpdate = self!.allGames[gameID]!.allPlayers[self!.localPlayer.playerID]!.score
            //this should be more targeted to the player that reconnected
            self!.socket.emit("last-score-update",
                ["gameID" : gameID,
                 "playerID"  : self!.localPlayer.playerID,
                 "lastScoreUpdate" : lastScoreUpdate ])
        }
        
//        socket.on("room-list") {[weak self] data, ack in
//            let received = data?[0] as? NSDictionary
//            let rooms: AnyObject? = received?.objectForKey("rooms")
//            l.o.g("\n\(rooms)")
//        }
//		
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
