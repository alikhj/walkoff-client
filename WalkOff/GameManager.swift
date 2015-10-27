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

class GameManager: NSObject, GameKitHelperDelegate {
	
	class var sharedInstance: GameManager {
		return GameManagerSingleton
	}
	
	//let socket = SocketIOClient(socketURL: "http://162.243.138.39")
  let socket = SocketIOClient(socketURL: "192.168.0.4:2000")

	let localPlayer = GKLocalPlayer.localPlayer()
	var gameKitHelper = GameKitHelper()
	var games = [String : Game]()
	var players = [String: Player]()
	weak var delegate: GameManagerDelegate?
	var allGKPlayers = [GKPlayer]()
	
	func startNetworking() {
		l.o.g("Networking started...")
		gameKitHelper.delegate = self
		socket.connect()
		handlers()
	}
	
	func gameKitHelper(newPlayersFound arrayOfPlayersFound: [GKPlayer]) {
		//create an array of playerIDs to for the server to use as tmpGameIDKey
		allGKPlayers = arrayOfPlayersFound
		allGKPlayers.append(localPlayer)
		
		var playerIDs = [String]()
		
		for player in allGKPlayers {
			playerIDs.append(player.playerID!)
		}
		
		let playerIDsCount = playerIDs.count
		let gamesCount = games.count
		
		//make the playerIDs array consistent across players by sorting it
		//alphabetically – this will be used as the tmpGameIDKey
		playerIDs.sortInPlace{ $0 > $1 }
		l.o.g("\nLocal player ID is \(localPlayer.playerID!)")
		l.o.g("\nJoining game with playerIDs array: \(playerIDs)")
		
		socket.emit("new-game", [
		 "playerIDs": playerIDs,
		 "playerID": localPlayer.playerID!,
		 "alias": localPlayer.alias!,
		 "playerCount": playerIDsCount,
		 "clientGamesCount": gamesCount
		])
	}
	
	func emitUpdatedScore(gameID: String, updatedScore: Int) {
		socket.emit("update-score", [
			"gameID": gameID,
			"playerID": localPlayer.playerID!,
			"newScore"  : updatedScore
		])
		
		l.o.g("\(gameID) emitting new score as \(updatedScore)")
		delegate?.gameManager(scoreUpdatedForGame: gameID)
	}
	
	func emitUpdatedItem(
		gameID: String,
		itemType: String,
		itemIndex: Int,
		itemName: String
	) {
		
		print("emitting type: \(itemType)")
		socket.emit("update-item", [
			"gameID": gameID,
			"playerID": localPlayer.playerID!,
			"itemType": itemType,
			"itemIndex": itemIndex,
			"itemName": itemName
		])
	}
  
  func leaveGame(gameID: String, playerID: String) {
    socket.emit("leave-game", [
      "gameID": gameID,
      "playerID": playerID
    ])
		
		
		for player in games[gameID]!.rankedPlayerIDs {
			
			if (player != localPlayer.playerID) {
				if (players[player]!.games.count > 1) {
					let index = players[player]!.games.indexOf(gameID)
					players[player]!.games.removeAtIndex(index!)
				
				} else {
					players.removeValueForKey(player)
				}
			}
		}
		
		games.removeValueForKey(gameID)
		
//		do this after game timer has ended:
//		let index = find(players[playerID]!.games, gameID)
//		players[playerID]!.games.removeAtIndex(index!)
  }
	
  func createGame(gameData: NSDictionary) {
    let newGame = Game(gameData: gameData)
    games[newGame.gameID] = newGame
    delegate?.gameManager(newGameCreated: newGame.gameID)
    allGKPlayers.removeAll(keepCapacity: false)
    if Movement.sharedInstance.isCountingSteps == false {
      Movement.sharedInstance.startCountingSteps()
			Movement.sharedInstance.startReadingMovementType()
    }
  }
  
  func createPlayer(playerData: NSArray) {
    for player in playerData {
      let playerID = player.valueForKey("id") as! String
      let playerAlias = player.valueForKey("alias") as! String
      //only add player if player doesn't exist in dictionary
      if((players[playerID]) == nil) {
        players[playerID] = Player(playerID: playerID, playerAlias: playerAlias)
      }
    }
  }
  
	func handlers() {
		socket.on("connect") { data, ack in
			l.o.g("Connected, with sid: \(self.socket.sid!)")
			
			let gamesCount = self.games.count
			
			self.socket.emit("player-connected", [
				"playerID": self.localPlayer.playerID!,
				"playerAlias": self.localPlayer.alias!,
        "clientGamesCount": gamesCount
			])
		}
    
		socket.on("reconnect") { data, ack in
			l.o.g("Disconnected, trying to reconnect...")
			self.delegate?.gameManagerWasDisconnected()
			self.socket.connect()
		}
		
    socket.on("game-started") { data, ack in
      l.o.g("game-started received by socket")
      let received = data[0] as? NSDictionary
			let gameData = received?.objectForKey("gameData") as! NSDictionary
      let playerData = received?.objectForKey("playerData") as! NSArray
			self.createPlayer(playerData)
      self.createGame(gameData)
    }
    
    socket.on("all-data") { data, ack in
      l.o.g("all-data received by socket... ")
			let received = data[0] as? NSDictionary
			let games = received?.objectForKey("gamesData") as! NSArray
			let players = received?.objectForKey("playerData") as! NSArray

      //only add games if they don't exist already
      if (self.games.count == 0) {
				self.createPlayer(players)

				for game in games {
          let gameData = game as! NSDictionary
          self.createGame(gameData)
        }
      }
    }
    
    socket.on("player-disconnected") { data, ack in
      let received = data[0] as? NSDictionary
      let playerID = received?.objectForKey("playerID") as! String
      let gameID = received?.objectForKey("gameID") as! String
      self.players[playerID]?.connected = false
      l.o.g("\n\(playerID) was disconnected from \(gameID)")
    }
    
    socket.on("player-reconnected") { data, ack in
      let received = data[0] as? NSDictionary
      let playerID = received?.objectForKey("playerID") as! String
      let gameID = received?.objectForKey("gameID") as! String
      self.players[playerID]?.connected = true
      l.o.g("\n\(playerID) has reconnected to \(gameID)")
    }
    
    socket.on("score-updated") { data, ack in
        print("score-updated received")
        let received = data[0] as? NSDictionary
        let gameID = received?.objectForKey("gameID") as! String
        let playerID = received?.objectForKey("playerID") as! String
        let newScore = received?.objectForKey("newScore") as! Int
        l.o.g("\nscore-update\ngameID: \(gameID)\nplayerID: \(playerID)\nnewScore: \(newScore)")
        let game = self.games[gameID]
        game?.updateScoreForOtherPlayer(playerID, newScore: newScore)
				self.delegate?.gameManager(scoreUpdatedForGame: gameID)
    }
		
		socket.on("item-updated") { data, ack in
			print("item-updated received")
			let received = data[0] as? NSDictionary
			let gameID = received?.objectForKey("gameID") as! String
			let playerID = received?.objectForKey("playerID") as! String
			let itemType = received?.objectForKey("itemType") as! String
			let itemIndex = received?.objectForKey("itemIndex") as! Int
			let itemName = received?.objectForKey("itemName") as! String
			
			let game = self.games[gameID]
			
			print(itemType)
			
			game?.updateItemForOtherPlayer(
				playerID,
				itemType: itemType,
				itemIndex: itemIndex,
				itemName: itemName
			)
		}
	}
	
	func debugHandlers() {
		self.socket.onAny {
			l.o.g("Got event: \($0.event), with items: \($0.items)")
		}
	}
}
