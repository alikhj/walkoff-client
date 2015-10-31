//
//  PowerDown_.swift
//  WalkOff
//
//  Created by Ali Khawaja on 10/28/15.
//  Copyright © 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum PowerDown: String {
    
    case dizzy = "dizzy"
}

func getPowerDown(powerDownID: PowerDown) -> (
name: String,
description: String,
divider: Double,
duration: Double
) {
    
    var powerDown: (
    name: String,
    description: String,
    divider: Double,
    duration: Double
    )
    
    switch powerDownID {
        
    case .dizzy:
        powerDown.name = "😵"
        powerDown.description = "😵 = 💤🚶💤"
        powerDown.divider = 2.0
        powerDown.duration = 10.0
    }
    
    return powerDown
}