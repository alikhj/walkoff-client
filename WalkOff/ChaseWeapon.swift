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
}

func getChaseWeapon(chaseWeaponID: ChaseWeapon) -> Chase {
    
    var chaseID: Chase
    
    switch chaseWeaponID {
        
    case .bees:
        chaseID = Item(chaseID: Chase.bees).chaseID!
    }
    
    return chaseID
}