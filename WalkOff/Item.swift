//
//  Item.swift
//  WalkOff
//
//  Created by Ali Khawaja on 10/28/15.
//  Copyright © 2015 Candy Snacks. All rights reserved.
//

import Foundation

class Item {
    
    var powerUpID: PowerUp?
    var powerDownID: PowerDown?
    var chaseID: Chase?
    var challengeID: Challenge?
    var chaseWeaponID: ChaseWeapon?
    
    init(powerUpID: PowerUp) {
        self.powerUpID = powerUpID
    }
    
    init(powerDownID: PowerDown) {
        self.powerDownID = powerDownID
    }
    
    init(chaseID: Chase) {
        self.chaseID = chaseID
    }
    
    init(challengeID: Challenge) {
        self.challengeID = challengeID
    }
    
    init(chaseWeaponID: ChaseWeapon) {
        self.chaseWeaponID = chaseWeaponID
    }
}



