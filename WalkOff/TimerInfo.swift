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
    var index: Int
    
    var previousScore: Int?
    
    init(item: Item, index: Int) {
        self.item = item
        self.index = index
    }
    
    init(item: Item, index: Int, previousScore: Int) {
        self.item = item
        self.index = index
        self.previousScore = previousScore
    }
    
}