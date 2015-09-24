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
	description: String,
	duration: Double,
	verification: ((Int, Int) -> AnyObject?)) {
		
  var challenge: (
		name: String,
		description: String,
		duration: Double,
		verification: ((Int, Int) -> AnyObject?)
  )
		
  switch challengeName {
		
		case .bees:
		
			func verification(previousScore: Int, currentScore: Int) -> AnyObject? {
				let difference = currentScore - previousScore
				if difference < 10 {
					return PowerUp.bees as? AnyObject
				} else {
					return (nil)
				}
			}
			
			challenge.name = "🐝"
			challenge.description = "15 steps to avoid bees"
			challenge.duration = 10
			challenge.verification = verification
		
		return challenge
	}
	
}