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

  var milestones: [(steps: Int, name: String, itemRawValue: String)]
  
  override init() {
    
    milestones = [
      (10, "getting started", PowerUp.secretariat.rawValue),
			(20, "getting started", Challenge.bees.rawValue),
			(30, "getting started", PowerUp.secretariat.rawValue),
      (40, "bees challenge", Challenge.bees.rawValue),
      (60, "aww yeah", PowerUp.rocket.rawValue)
    ]
  }
  
	func evaluateScoreForMilestone(currentScore: Int, previousScore: Int) -> (
  name: String, itemRawValue: String)? {
	

    for milestone in milestones {
      
      if ((previousScore < milestone.steps) && (currentScore >= milestone.steps)) {
        
        return (milestone.name, milestone.itemRawValue)
      }
    
    }
    return nil
	
  }
  
}