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
  class var sharedInstance: Milestones {
    return MilestonesSingleton
  }

	
  var milestones: [(steps: Int, name: String, powerUpID: PowerUp)]
  
  override init() {
    
    milestones = [
      (20, "getting started", PowerUp.skateboard),
      (50, "20 steps!!", PowerUp.jetpack),
      (80, "aww yeah", PowerUp.unicorn),
			(1020, "challenge!", PowerUp.challenge)
    ]
  }
  
	func evaluateScoreForMilestone(currentScore: Int, previousScore: Int) -> (
  name: String?, powerUpID: PowerUp?) {
		
    var name: String?
    var powerUpID: PowerUp?
      
    for milestone in milestones {
      
      if ((previousScore < milestone.steps) && (currentScore >= milestone.steps)) {
        
        name = milestone.name
        powerUpID = milestone.powerUpID
      } 
    }
      
    return (name, powerUpID)
	}
}