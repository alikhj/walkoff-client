//
//  Player.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit
import GameKit

class Player: NSObject {
  
    var playerID: String?
    var playerAlias: String?
    var gameIDs: [String] = []
    var connected: Bool?
    var movementType: String?

    var score: Int?
    var inGame: Bool?
    
    var powerUps = [String]()
    var powerDowns = [String]()
    var challenges = [String]()
    var chases = [String]()

    init(score: Int, inGame: Bool) {
        self.score = score
        self.inGame = inGame

        powerUps.reserveCapacity(10)
        powerDowns.reserveCapacity(10)
        challenges.reserveCapacity(10)
        chases.reserveCapacity(10)
    }
  
    init(
        playerID: String,
        playerAlias: String,
        gameIDs: [String],
        isConnected: Bool,
        movementType: String
    ) {
        self.playerID = playerID
        self.playerAlias = playerAlias
        self.gameIDs = gameIDs
        self.connected = isConnected
        self.movementType = movementType
    }
}
