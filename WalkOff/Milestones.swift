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
            (25, "getting started", Item(chaseWeaponID: ChaseWeapon.bees)),
            (30, "getting started", Item(powerDownID: PowerDown.hurt)),
            (45, "getting started", Item(challengeID: Challenge.poo)),
            (60, "bees challenge", Item(chaseID: Chase.bees)),
            (5, "offense", Item(chaseWeaponID: ChaseWeapon.bees)),
            (15, "offense", Item(chaseWeaponID: ChaseWeapon.bees))
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