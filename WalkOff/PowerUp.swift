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
	case challenge = "challenge"
	case bees = "bees"
	case dead = "dead"
}

func getPowerUp(powerUpName: PowerUp) -> (
	name: String,
  description: String,
	multiplier: Double,
	duration: Double,
	verify: ((Int, Int) -> PowerUp?)?) {
	
  var powerUp: (
    name: String,
    description: String,
    multiplier: Double,
    duration: Double,
	  verify: ((Int, Int) -> PowerUp?)?
  )
		
  switch powerUpName {
    
  case .secretariat:
    powerUp.name = "🏇"
    powerUp.description = "Double your steps"
    powerUp.multiplier = 2
    powerUp.duration = 10
		powerUp.verify = nil
    //add function to undo multipliers
    //add function to check reward/goal
    
  case .dancingBeans:
    powerUp.name = "💃"
    powerUp.description = "Triple your steps"
    powerUp.multiplier = 5
    powerUp.duration = 10
		powerUp.verify = nil
    
  case .rocket:
    powerUp.name = "🚀"
    powerUp.description = "5x your steps"
    powerUp.multiplier = 10
    powerUp.duration = 10
		powerUp.verify = nil
		
	case .dead:
		powerUp.name = "💀"
		powerUp.description = "half steps"
		powerUp.multiplier = 0.5
		powerUp.duration = 10
		powerUp.verify = nil
		
	case .bees:
		
		func verifyFunc(previousScore: Int, currentScore: Int) -> PowerUp? {
			
			let difference = currentScore - previousScore
			if difference < 10 {
				return PowerUp.dead
			} else {
				return (nil)
			}
		}
		
		powerUp.name = "🐝"
		powerUp.description = "10 steps in 10 min to outrun bees"
		powerUp.multiplier = 1
		powerUp.duration = 10
		powerUp.verify = verifyFunc
		
	case .challenge:
		
		func verifyFunc(previousScore: Int, currentScore: Int) -> PowerUp? {
		
      let difference = currentScore - previousScore
			if difference > 10 {
				return PowerUp.dancingBeans
			} else {
				return (nil)
			}
		}
		
		powerUp.name = "💪"
    powerUp.description = "Win a rocket!"
		powerUp.multiplier = 1
		powerUp.duration = 15
		powerUp.verify = verifyFunc
  }
	
	return powerUp
}