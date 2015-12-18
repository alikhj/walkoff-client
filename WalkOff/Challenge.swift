//
//  Challenge.swift
//  WalkOff
//
//  Created by Ali Khawaja on 10/28/15.
//  Copyright © 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum Challenge: String {
    
    case poop = "poop"
}

func getChallenge(challengeID: Challenge) -> ((
name: String,
description: String,
numberOfSteps: Int,
duration: Double,
verification: ((previousScore: Int, currentScore: Int) -> Item?)
)) {
    
    var name: String
    var description: String
    var numberOfSteps: Int
    var duration: Double
    
    var item: Item?
    
    switch challengeID {
        
    case .poop:
        name = "💩"
        description = "💩🏃⏱🔟"
        numberOfSteps = 20
        duration = 10.0
        item = Item(powerDownID: PowerDown.hurt)
    }
    
    func verification(previousScore: Int, currentScore: Int) -> Item? {
        
        let difference = currentScore - previousScore
        if difference < numberOfSteps {
            return item
        } else { return nil }
    }
    
    return (
        name,
        description,
        numberOfSteps,
        duration,
        verification
    )
}
        