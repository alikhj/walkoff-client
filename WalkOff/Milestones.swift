//
//  Milestones.swift
//  WalkOff
//
//  Created by Ali Khawaja on 9/15/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import Foundation

let MilestonesSingleton = Milestones()


class Milestones: NSObject {
	
	var mileStones = [
		5,
		20,
		40
	]
	
	class var sharedInstance: Milestones {
		return MilestonesSingleton
}

//	func evaluateScoreForMilestone(score: Double, lastMileStone: Int) ->
//	(mileStoneName: String?, powerUp: PowerUp) {
//		
//			
//	}
	
}