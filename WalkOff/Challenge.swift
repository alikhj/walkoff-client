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
}

func getChallenge(challengeName: Challenge) -> (
	name: String,
	numberOfSteps: Int,
	duration: Double,
	itemType: String,
	itemRawValue: String,
	description: String,
	verification: ((Int, Int) -> (type: String, rawValue: String)?)
) {
		
  var challenge: (
		name: String,
		numberOfSteps: Int,
		duration: Double,
		itemType: String,
		itemRawValue: String,
		description: String,
		verification: ((Int, Int) -> (type: String, rawValue: String)?)
  )
		
  switch challengeName {
		
		case .bees:
			
			challenge.name = "🐝"
			challenge.numberOfSteps = 50
			challenge.duration = 10
			challenge.itemRawValue = PowerDown.dead.rawValue
			challenge.itemType = String(PowerDown.self)
			
			let itemID = PowerDown(rawValue: challenge.itemRawValue)!
			let powerDown = getPowerDown(itemID)
			
			challenge.description =
			"\(challenge.numberOfSteps) steps in \(challenge.duration) seconds or else \(powerDown.name)"

			
			func verification(previousScore: Int, currentScore: Int) ->
				(type: String, rawValue: String)? {
					
					let difference = currentScore - previousScore
					
					if difference < 10 {
						
						return (String(PowerDown.self), PowerDown.dead.rawValue)
						
					} else {
						print("diff is else")
						return (nil)
					}
			}
			
			challenge.verification = verification
			

		
		return challenge
	}
}