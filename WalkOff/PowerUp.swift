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
}

func getPowerUp(powerUpName: PowerUp) -> ((
	name: String,
	multiplier: Double,
	duration: Double,
	verify: ((Int, Int) -> (multiplier: Double?, powerUpID: PowerUp?))?
)) {
	
  var powerUp: (
    name: String,
    multiplier: Double,
    duration: Double,
	  verify: ((Int, Int) -> (multiplier: Double?, powerUpID: PowerUp?))?
  )
		
  switch powerUpName {
    
  case .secretariat:
    powerUp.name = "🏇"
    powerUp.multiplier = 2
    powerUp.duration = 10
		powerUp.verify = nil
    //add function to undo multipliers
    //add function to check reward/goal
    
  case .dancingBeans:
    powerUp.name = "💃"
    powerUp.multiplier = 5
    powerUp.duration = 10
		powerUp.verify = nil
    
  case .rocket:
    powerUp.name = "🚀"
    powerUp.multiplier = 10
    powerUp.duration = 10
		powerUp.verify = nil
		
	case .challenge:
		
		func verifyFunc(previousScore: Int, currentScore: Int) -> (multiplier: Double?, powerUpID: PowerUp?) {
			let difference = currentScore - previousScore
			if difference > 10 {
				return (5.0, PowerUp.dancingBeans)
			} else {
				return (1.0, nil)
			}
		}
		
		powerUp.name = "💪"
		powerUp.multiplier = 1
		powerUp.duration = 15
		powerUp.verify = verifyFunc
		

  }
	
	return powerUp
}