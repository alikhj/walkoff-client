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

func getChallengeWeapon(challengeWeaponID: ChallengeWeapon) -> Challenge {
    
    var challengeID: Challenge
    
    switch challengeWeaponID {
        
    case .poop:
        challengeID = Item(challengeID: Challenge.poop).challengeID!
    }
    
    return challengeID
}