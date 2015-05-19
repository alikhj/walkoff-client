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
	
	var gkPlayer: GKPlayer
	var score: Int
	
	init(gkPlayer: GKPlayer) {
		self.gkPlayer = gkPlayer
		score = 0
	}
}
