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
      (10, "getting started", PowerUp.secretariat),
      (30, "20 steps!!", PowerUp.dancingBeans),
      (60, "aww yeah", PowerUp.rocket),
			(100, "challenge!", PowerUp.challenge)
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