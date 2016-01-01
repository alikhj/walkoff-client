//
//  ChaseWeapon.swift
//  WalkOff
//
//  Created by Ali Khawaja on 10/29/15.
//  Copyright © 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum ChaseWeapon: String {
    
    case bees = "bees"
//    case cheetah = "cheetah"
//    case bull = "bull"
//    case tiger = "tiger"
//    case cop = "cop"
//    case gun = "gun"
}

func getChaseWeapon(chaseWeaponID: ChaseWeapon) -> (description: String, chaseID: Chase) {
    
    var chaseWeapon: (description: String, chaseID: Chase)

    switch chaseWeaponID {
        
    case .bees:
        chaseWeapon.chaseID = Item(chaseID: Chase.bees).chaseID!
        chaseWeapon.description = "Unleash the bees"
    }
    
    return chaseWeapon
}