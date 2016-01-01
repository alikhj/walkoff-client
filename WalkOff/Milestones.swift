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

    var milestones: [(
        steps: Int,
        name: String,
        item: Item
    )]
	
    override init() {
    
        milestones = [
            (15, "getting started", Item(chaseWeaponID: ChaseWeapon.bees)),
            (25, "getting started", Item(challengeWeaponID: ChallengeWeapon.poop)),
            (40, "getting started", Item(challengeWeaponID: ChallengeWeapon.rain))
        ]
    }
	
	func evaluateScoreForMilestone(currentScore: Int, previousScore: Int) ->
    (name: String, item: Item)? {
	
        var thisMilestone: (name: String, item: Item)?

        for milestone in milestones {
            if ((previousScore < milestone.steps) && (currentScore >= milestone.steps)) {
                thisMilestone = (milestone.name, milestone.item)
            }
        }
        
        return thisMilestone
    }
}