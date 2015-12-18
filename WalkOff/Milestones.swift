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
            (40, "getting started", Item(chaseWeaponID: ChaseWeapon.bees)),
            (50, "getting started", Item(chaseWeaponID: ChaseWeapon.bees)),
            (100, "getting started", Item(chaseWeaponID: ChaseWeapon.bees)),
            (775, "getting started", Item(chaseWeaponID: ChaseWeapon.bees)),
            
            (50, "getting started", Item(challengeWeaponID: ChallengeWeapon.poop)),
            (55, "getting started", Item(challengeWeaponID: ChallengeWeapon.poop)),
            (105, "getting started", Item(challengeWeaponID: ChallengeWeapon.poop)),
            (205, "getting started", Item(challengeWeaponID: ChallengeWeapon.poop)),
            (305, "getting started", Item(challengeWeaponID: ChallengeWeapon.poop))
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