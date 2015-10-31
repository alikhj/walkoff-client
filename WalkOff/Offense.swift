//
//  Offense.swift
//  WalkOff
//
//  Created by Ali Khawaja on 10/29/15.
//  Copyright © 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum Offense: String {
    
    case bees = "bees"
}

func getOffense(offenseID: Offense) -> Item {
    
    var offense: Item
    
    switch offenseID {
        
    case .bees:
        offense = Item(chaseID: Chase.bees)
    }
    
    return offense
}