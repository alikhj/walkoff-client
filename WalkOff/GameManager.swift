//
//  Networking.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit
import GameKit

@objc protocol GameManagerDelegate: class {
    optional func gameManagerInvitationReceived()
    optional func gameManager(newGameCreated gameID: String)
    optional func gameManager(scoreUpdatedForGame gameID: String)
    optional func gameManagerWasDisconnected()
}

let GameManagerSingleton = GameManager()

class GameManager: NSObject, GameKitHelperDelegate, MovementDelegate {
	
	class var sharedInstance: GameManager {
		return GameManagerSingleton
	}
    
//    #if arch(i386) || arch(x86_64)
//    let socket = SocketIOClient(socketURL: "localhost:2000")
//
//    #else
//    let socket = SocketIOClient(socketURL: "192.168.0.10:2000")
//
//    #endif
    
    let socket = SocketIOClient(socketURL: "http://192.168.0.6:2000")
    
    var gameIDs = [String]()
    var invitations = [NSDictionary]()
    
	let localPlayer = GKLocalPlayer.localPlayer()
	var gameKitHelper = GameKitHelper()
	
    var games = [String : Game]()
	var players = [String: Player]()
	
    weak var delegate: GameManagerDelegate?
	var allGKPlayers = [GKPlayer]()
	
	func startNetworking() {
        
        Movement.sharedInstance.delegate = self
		l.o.g("Networking started...")
		gameKitHelper.delegate = self
		socket.connect()
		handlers()
	}
	
	func gameKitHelper(newPlayersFound arrayOfPlayersFound: [GKPlayer]) {
		//create an array of playerIDs for the server to use as tmpGameIDKey
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
	
    func createGame(gameData: NSDictionary) {
        let newGame = Game(gameData: gameData)
        games[newGame.gameID] = newGame
        gameIDs.append(newGame.gameID)
        
        delegate?.gameManager!(newGameCreated: newGame.gameID)
        allGKPlayers.removeAll(keepCapacity: false)
    }
    
    func createPlayer(playerData: NSArray) {
        for player in playerData {
            let playerID = player.valueForKey("id") as! String
            let playerAlias = player.valueForKey("alias") as! String
            let isConnected = player.valueForKey("connected") as! Bool
            let movementType = player.valueForKey("movementType") as! String

            //only add player if player doesn't exist in dictionary
            if((players[playerID]) == nil) {
                players[playerID] = Player(
                    playerID: playerID,
                    playerAlias: playerAlias,
                    isConnected: isConnected,
                    movementType: movementType
                )
            }
        }
    }

    func movementUpdated() {
        
        players[localPlayer.playerID!]!.movementType = Movement.sharedInstance.movementType
        
        var gameScores = [String : Int]()
        for (gameID, game) in games {
            game.delegate?.game(itemUpdatedForPlayer: localPlayer.playerID!)
            gameScores[gameID] = game.playerData[localPlayer.playerID!]!.score
        }
        
        socket.emit("update-movement", [
            "playerID": localPlayer.playerID!,
            "movementType": Movement.sharedInstance.movementType,
            "gameScores": gameScores
        ])
    }
    
    func invitePlayers(players: [String: String]) {
        socket.emit("new-invitation", [
            "invitedPlayers": players,
            "playerID": localPlayer.playerID!,
            "alias": localPlayer.alias!
        ])
    }
	
    func checkForInvitations() {
        print("checking for invitations...")
        
        socket.emit("check-invitations", [
            "playerID": localPlayer.playerID!
        ])
        
//        if let lastInvitationID = invitationIDs.last {
//           
//            socket.emit("check-invitations", [
//                "playerID": localPlayer.playerID!,
//                "lastInvitationID": lastInvitationID
//            ])
//        
//        } else {
//            socket.emit("check-invitations", [
//                "playerID": localPlayer.playerID!,
//                "lastInvitationID": "none"
//            ])
//        }
    }
    
    func acceptInvitationForGame(invitationID: String, index: Int) {
        socket.emit("accept-invitation", [
            "playerID": localPlayer.playerID!,
            "invitationID": invitationID,
            "index": index
        ])
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
  
    func emitWeapon(
    gameID: String,
    toPlayerID: String,
    itemType: String,
    rawValue: String
    ) {
        
        print("emitting weapon: \(itemType) \(rawValue)")
        
        socket.emit("weapon-fired", [
            "gameID": gameID,
            "toPlayerID": toPlayerID,
            "itemType": itemType,
            "rawValue": rawValue
        ])
    }
    
    func leaveGame(gameID: String, playerID: String) {
        
        socket.emit("leave-game", [
            "gameID": gameID,
            "playerID": playerID
        ])
        
        for playerID in games[gameID]!.rankedPlayerIDs {
            
            if (playerID != localPlayer.playerID) {
                if (players[playerID]!.gameIDs.count > 1) {
                    let index = players[playerID]!.gameIDs.indexOf(gameID)
                    players[playerID]!.gameIDs.removeAtIndex(index!)
                    
                } else {
                    players.removeValueForKey(playerID)
                }
            }
        }
        
        games.removeValueForKey(gameID)
        
        //		do this after game timer has ended:
        //		let index = find(players[playerID]!.games, gameID)
        //		players[playerID]!.games.removeAtIndex(index!)
    }
    
	func handlers() {
		
        socket.on("connect") { data, ack in
			l.o.g("Connected, with sid: \(self.socket.sid!)")
			
			let gamesCount = self.games.count
            self.checkForInvitations()

			self.socket.emit("player-connected", [
				"playerID": self.localPlayer.playerID!,
				"playerAlias": self.localPlayer.alias!,
                "movementType" : Movement.sharedInstance.movementType,
                "clientGamesCount": gamesCount
			])
		}
    
		socket.on("reconnect") { data, ack in
			l.o.g("Disconnected, trying to reconnect...")
			self.delegate?.gameManagerWasDisconnected!()
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
        
        socket.on("invitations") { data, ack in
            l.o.g("new-invitation received by socket")
            let received = data[0] as! NSDictionary
            let invitations = received.objectForKey("invitations") as! NSArray
            self.invitations = invitations as! [NSDictionary]
            self.delegate?.gameManagerInvitationReceived!()
        }
    
        socket.on("all-data") { data, ack in
            l.o.g("all-data received by socket... ")
            let received = data[0] as? NSDictionary
			let games = received?.objectForKey("gamesData") as! NSArray
			let players = received?.objectForKey("playerData") as! NSArray

            //only add games and players if they don't exist already (ie app was restarted)
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
          let game = self.games[gameID]
          game?.delegate?.game(itemUpdatedForPlayer: playerID)
          l.o.g("\n\(playerID) was disconnected from \(gameID)")
        }
    
        socket.on("player-reconnected") { data, ack in
          let received = data[0] as? NSDictionary
          let playerID = received?.objectForKey("playerID") as! String
          let gameID = received?.objectForKey("gameID") as! String
          self.players[playerID]?.connected = true
          let game = self.games[gameID]
          game?.delegate?.game(itemUpdatedForPlayer: playerID)
          l.o.g("\n\(playerID) has reconnected to \(gameID)")
        }
        
        socket.on("player-left-game") { data, ack in
            let received = data[0] as? NSDictionary
            let playerID = received?.objectForKey("playerID") as! String
            let gameID = received?.objectForKey("gameID") as! String
            let game = self.games[gameID]!
            game.playerQuitGame(playerID)
            game.delegate?.game(itemUpdatedForPlayer: playerID)
        }
    
        socket.on("movement-updated") { data, ack in
            let received = data[0] as? NSDictionary
            let gameID = received?.objectForKey("gameID") as! String
            let playerID = received?.objectForKey("playerID") as! String
            let newScore = received?.objectForKey("newScore") as! Int
            let movementType = received?.objectForKey("movementType") as! String

            self.players[playerID]?.movementType = movementType
            
            l.o.g("\nscore-update\ngameID: \(gameID)\nplayerID: \(playerID)\nnewScore: \(newScore)")
            let game = self.games[gameID]
            game?.updateScoreForOtherPlayer(playerID, newScore: newScore)
            //self.delegate?.gameManager!(scoreUpdatedForGame: gameID)
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
						
			game?.updateItemForOtherPlayer(
				playerID,
				itemType: itemType,
				itemIndex: itemIndex,
				itemName: itemName
			)
        }
        
        socket.on("weapon-received") { data, ack in
            print("weapon received")
            let received = data[0] as? NSDictionary
            let gameID = received?.objectForKey("gameID") as! String
            let itemType = received?.objectForKey("itemType") as! String
            let rawValue = received?.objectForKey("rawValue") as! String
            
            let game = self.games[gameID]
            
            game?.receiveWeapon(itemType, rawValue: rawValue)
        }
    }
	
	func debugHandlers() {
		self.socket.onAny {
			l.o.g("Got event: \($0.event), with items: \($0.items)")
		}
	}
}
