//
//  PowerUp.swift
//  WalkOff
//
//  Created by Ali Khawaja on 9/15/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum PowerUp: String {
	case secretariat = "secretariat"
	case dancingBeans = "dancing beans"
	case rocket = "rocket"
}

func getPowerUp(powerUpName: PowerUp) -> (
	name: String,
  description: String,
	multiplier: Double,
	duration: Double) {
	
  var powerUp: (
    name: String,
    description: String,
    multiplier: Double,
    duration: Double
  )
		
  switch powerUpName {
    
  case .secretariat:
    powerUp.name = "🏇"
    powerUp.description = "Double your steps"
    powerUp.multiplier = 2
    powerUp.duration = 10
    //add function to undo multipliers
    //add function to check reward/goal
    
  case .dancingBeans:
    powerUp.name = "💃"
    powerUp.description = "Triple your steps"
    powerUp.multiplier = 5
    powerUp.duration = 10
    
  case .rocket:
    powerUp.name = "🚀"
    powerUp.description = "5x your steps"
    powerUp.multiplier = 10
    powerUp.duration = 10
		
  }
	return powerUp
}