//
//  PowerUp.swift
//  WalkOff
//
//  Created by Ali Khawaja on 9/15/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import Foundation

enum PowerDown: String {
  case dead = "dead"
	case rain = "rain"
}


func getPowerDown(powerDownName: PowerDown) -> (
  name: String,
  description: String,
  divider: Double,
  duration: Double) {
    
    var powerDown: (
      name: String,
      description: String,
      divider: Double,
      duration: Double
    )
    
    switch powerDownName {
      
    case .dead:
      powerDown.name = "💀"
      powerDown.description = "you're dead"
      powerDown.divider = 2
      powerDown.duration = 15
		
		case .rain:
			powerDown.name = "☔️"
			powerDown.description = "its raining"
			powerDown.divider = 2
			powerDown.duration = 15
		}
		
		return powerDown

}

