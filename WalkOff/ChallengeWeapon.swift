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
    case bananaPeel = "bananaPeel"
    case bomb = "bomb"
    case potHole = "potHole"
    case spiderWeb = "spiderWeb"
    case rain = "rain"
    case barricade = "barricade"
}

func getChallengeWeapon(challengeWeaponID: ChallengeWeapon) ->
    (description: String, challengeID: Challenge)
{
    
    var challengeWeapon: (description: String, challengeID: Challenge)
    
    switch challengeWeaponID {
        
    case .poop:
        challengeWeapon.challengeID = Item(challengeID: Challenge.poop).challengeID!
        challengeWeapon.description = "Drop a turd bomb"
        
    case .bananaPeel:
        challengeWeapon.challengeID = Item(challengeID: Challenge.bananaPeel).challengeID!
        challengeWeapon.description = "Drop a banana peel"
        
    case .bomb:
        challengeWeapon.challengeID = Item(challengeID: Challenge.bomb).challengeID!
        challengeWeapon.description = "Drop a bomb"
        
    case .potHole:
        challengeWeapon.challengeID = Item(challengeID: Challenge.potHole).challengeID!
        challengeWeapon.description = "Make a pothole"
        
    case .spiderWeb:
        challengeWeapon.challengeID = Item(challengeID: Challenge.spiderWeb).challengeID!
        challengeWeapon.description = "Make a spiderweb"
        
    case .rain:
        challengeWeapon.challengeID = Item(challengeID: Challenge.rain).challengeID!
        challengeWeapon.description = "Make it rain"
        
    case .barricade:
        challengeWeapon.challengeID = Item(challengeID: Challenge.barricade).challengeID!
        challengeWeapon.description = "Build a barricade"
    }
    
    return challengeWeapon
}