//
//  PowerUp.swift
//  WalkOff
//
//  Created by Ali Khawaja on 9/15/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum PowerUp: String {
	case skateboard = "skateboard"
	case jetpack = "jetpack"
	case unicorn = "unicorn"
}

func getPowerUp(powerUpName: PowerUp) ->
((name: String, multiplier: Double, duration: Double)) {
	
  var powerUp: (
    name: String,
    multiplier: Double,
    duration: Double
  )
		
  switch powerUpName {
    
  case .skateboard:
    powerUp.name = "Skateboard"
    powerUp.multiplier = 2
    powerUp.duration = 10
    //add function to undo multipliers
    //add function to check reward/goal
    
  case .jetpack:
    powerUp.name = "Jetpack"
    powerUp.multiplier = 5
    powerUp.duration = 10
    
  case .unicorn:
    powerUp.name = "Unicorn"
    powerUp.multiplier = 10
    powerUp.duration = 10
  }
  
	return powerUp
}