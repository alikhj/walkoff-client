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
      (5, "getting started", PowerUp.skateboard),
      (20, "20 steps!!", PowerUp.jetpack),
      (50, "aww yeah", PowerUp.unicorn)
    ]
  }
  
	func evaluateScoreForMilestone(currentScore: Int, previousScore: Int) -> (
  name: String?, powerUpID: PowerUp?) {
		
    var name: String?
    var powerUpID: PowerUp?
      
    for milestone in milestones {
      
      if ((previousScore < milestone.steps) && (currentScore <= milestone.steps)) {
        
        name = milestone.name
        powerUpID = milestone.powerUpID
      } 
    }
      
    return (name, powerUpID)
	}
}