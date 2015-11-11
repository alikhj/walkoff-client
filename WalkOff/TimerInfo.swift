//
//  TimerInfo.swift
//  WalkOff
//
//  Created by Ali Khawaja on 10/29/15.
//  Copyright © 2015 Candy Snacks. All rights reserved.
//

import Foundation

class TimerInfo {
    
    var item: Item
    var UUID: String
    
    var previousScore: Int?
    
    init(item: Item, UUID: String) {
        self.item = item
        self.UUID = UUID
    }
    
    init(item: Item, UUID: String, previousScore: Int) {
        self.item = item
        self.UUID = UUID
        self.previousScore = previousScore
    }
    
}