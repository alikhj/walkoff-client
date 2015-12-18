//
//  PowerUp_.swift
//  WalkOff
//
//  Created by Ali Khawaja on 10/28/15.
//  Copyright © 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum PowerUp: String {
    
    case rocket = "rocket"
}

func getPowerUp(powerUpID: PowerUp) -> (
name: String,
description: String,
multiplier: Double,
duration: Double
) {
    
    var powerUp: (
    name: String,
    description: String,
    multiplier: Double,
    duration: Double
    )
    
    switch powerUpID {
        
    case .rocket:
        powerUp.name = "🚀"
        powerUp.description = "🚀 = 🚶🚶🚶🚶🚶"
        powerUp.multiplier = 5.0
        powerUp.duration = 10.0
    }
    
    return powerUp
}