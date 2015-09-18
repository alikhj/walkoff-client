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
	case challenge = "challenge"
}

func getPowerUp(powerUpName: PowerUp) -> ((
	name: String,
	multiplier: Double,
	duration: Double,
	verifyFunc: ((Int, Int) -> (multiplier: Double?, powerUpID: PowerUp?))?
)) {
	
  var powerUp: (
    name: String,
    multiplier: Double,
    duration: Double,
	  verifyFunc: ((Int, Int) -> (multiplier: Double?, powerUpID: PowerUp?))?
  )
		
  switch powerUpName {
    
  case .skateboard:
    powerUp.name = "Skateboard"
    powerUp.multiplier = 2
    powerUp.duration = 10
		powerUp.verifyFunc = nil
    //add function to undo multipliers
    //add function to check reward/goal
    
  case .jetpack:
    powerUp.name = "Jetpack"
    powerUp.multiplier = 5
    powerUp.duration = 10
		powerUp.verifyFunc = nil
    
  case .unicorn:
    powerUp.name = "Unicorn"
    powerUp.multiplier = 10
    powerUp.duration = 10
		powerUp.verifyFunc = nil
		
	case .challenge:
		
		func verify(previousScore: Int, currentScore: Int) -> (multiplier: Double?, powerUpID: PowerUp?) {
			var difference = currentScore - previousScore
			if difference > 10 {
				return (5.0, PowerUp.jetpack)
			} else {
				return (1.0, nil)
			}
		}
		
		powerUp.name = "challenge"
		powerUp.multiplier = 1
		powerUp.duration = 15
		powerUp.verifyFunc = verify
		

  }
	
	return powerUp
}