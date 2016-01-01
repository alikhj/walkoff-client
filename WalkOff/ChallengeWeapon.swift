//
//  ChallengeWeapon.swift
//  WalkOff
//
//  Created by Ali Khawaja on 12/17/15.
//  Copyright © 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum ChallengeWeapon: String {
    
    case poop = "poop"
}

func getChallengeWeapon(challengeWeaponID: ChallengeWeapon) ->
    (description: String, challengeID: Challenge)
{
    
    var challengeWeapon: (description: String, challengeID: Challenge)
    
    switch challengeWeaponID {
        
    case .poop:
        challengeWeapon.challengeID = Item(challengeID: Challenge.poop).challengeID!
        challengeWeapon.description = "Drop a turd bomb"
    }
    
    return challengeWeapon
}