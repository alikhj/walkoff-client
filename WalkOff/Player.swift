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
  var score: Int?
	
	var activity = ""
	var powerUps = [String]()
	var powerDowns = [String]()
	var challenges = [String]()
  
  var connected: Bool?
	var games: [String] = []
	
	init(score: Int) {
    self.score = score
		powerUps.reserveCapacity(10)
		
  }
  
  init(playerID: String, playerAlias: String) {
    self.playerID = playerID
    self.playerAlias = playerAlias
    connected = true
  }
  
}
