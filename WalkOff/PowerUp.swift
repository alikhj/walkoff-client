//
//  PowerUp.swift
//  WalkOff
//
//  Created by Ali Khawaja on 9/15/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum PowerUp {
	case skateBoard
	case jetPack
	case unicorn
}

func getPowerUp(powerUp: PowerUp?) ->
(multiplier: Double, duration: Double) {
	
	var multiplier: Double?
	var duration: Double?
	
	if let _ = powerUp {
		
		switch powerUp! {
			
		case .skateBoard:
			multiplier = 2
			duration = 10
			
		case .jetPack:
			multiplier = 5
			duration = 10
			
		case .unicorn:
			multiplier = 10
			duration = 10
		}
	} else {
		return (1.0, 0)
	}
	
	return (multiplier!, duration!)
}