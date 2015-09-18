//
//  Networking.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import Foundation
import GameKit

let ItemManagerSingleton = ItemManager()

class ItemManager: NSObject {
	
		class var sharedInstance: ItemManager {
			return ItemManagerSingleton
		}
	
	func evaluatePlayerData (playerData: [String : Player]) {

	}
	
	func evaluateScore(score: Int) -> Int {
		
		if (score < 100 && score > 10) {
			
			
		}
		
		return 1
	}
	
}
