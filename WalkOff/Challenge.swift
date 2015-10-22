//
//  challenge.swift
//  WalkOff
//
//  Created by Ali Khawaja on 9/15/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum Challenge: String {
	case bees = "bees"
	case liftOff = "liftOff"
}

func getChallenge(challengeID: Challenge) -> (
	name: String,
	numberOfSteps: Int,
	duration: Double,
	itemType: String,
	itemRawValue: String,
	description: String,
	verification: ((Int, Int) -> (type: String, rawValue: String)?)
) {

	var challengeName: String
	var numberOfSteps: Int
	var duration: Double
	var item: (type: String, rawValue: String)
	var description: String
	var verificationFunc: (previousScore: Int, currentScore: Int) ->
	(type: String, rawValue: String)?
	
  switch challengeID {
		
		case .bees:
			
			challengeName = "🐝"
			numberOfSteps = 50
			duration = 10
			item = (String(PowerDown.self), PowerDown.dizzy.rawValue)

			//make a function out of this
			let itemID = PowerDown(rawValue: item.rawValue)!
			let powerDown = getPowerDown(itemID)
			
			description =
			"\(numberOfSteps) steps in \(duration) seconds or else \(powerDown.name)"
		
		case .liftOff:
			
			challengeName = "🚦"
			numberOfSteps = 2
			duration = 10
			item = (String(PowerUp.self), PowerUp.rocket.rawValue)
			
			//make a function out of this
			let itemID = PowerUp(rawValue: item.rawValue)!
			let powerUp = getPowerUp(itemID)
			
			description =
			"\(numberOfSteps) steps in \(duration) seconds or else \(powerUp.name)"
		
	}
	
	func verification(previousScore: Int, currentScore: Int) ->
		(type: String, rawValue: String)? {
			
			let difference = currentScore - previousScore
			
			if difference < numberOfSteps {
				
				return (item.type, item.rawValue)
				
			} else {
				print("diff is else")
				return (nil)
			}
	}
	
	return (
		challengeName,
		numberOfSteps,
		duration,
		item.type,
		item.rawValue,
		description,
		verification
	)
}