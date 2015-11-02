//
//  Movement.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

let MovementSingleton = Movement()

class Movement: NSObject, CLLocationManagerDelegate {
	class var sharedInstance: Movement {
		return MovementSingleton
	}
		
	let pedometer = CMPedometer()
	let activityManager = CMMotionActivityManager()
	let locationManager = CLLocationManager()
    var isCountingSteps = false
	var previousTotalSteps = 0
	var currentTotalSteps = 0
	dynamic var stepsUpdate = 0
	dynamic var movementType = ""
	
	override init() {
        super.init()
        l.o.g("Movement initialized")
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		locationManager.requestAlwaysAuthorization()
		locationManager.pausesLocationUpdatesAutomatically = false //maybe?
		locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
	}
	
	func startCountingSteps() {
        isCountingSteps = true
        l.o.g("Start counting steps...")
		
        if(CMPedometer.isStepCountingAvailable()){
			pedometer.startPedometerUpdatesFromDate(NSDate()) {
				(data, error) in if error != nil {
					l.o.g("Error starting pedometer updates: \(error)")
				} else {
					dispatch_async(dispatch_get_main_queue()) {
                        if (data!.numberOfSteps as Int > 0) {
                          self.currentTotalSteps = data!.numberOfSteps as Int
                          self.stepsUpdate = self.currentTotalSteps - self.previousTotalSteps
                          self.previousTotalSteps = self.currentTotalSteps
                        }
					}
				}
			}
            
		} else { l.o.g("Pedometer not available") }
	}
	
	func startReadingMovementType() {
		
		if(CMMotionActivityManager.isActivityAvailable()) {
			self.activityManager.startActivityUpdatesToQueue(
            NSOperationQueue.mainQueue(), withHandler: {
                
                data in dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                
                    if (data!.walking) {
                        self.movementType = "🚶"

                    } else if (data!.running) {
                        self.movementType = "🏃"

                    } else if (data!.stationary) {
                        self.movementType = "💤"

                    } else if (data!.cycling) {
                      self.movementType = "🚴"
                    
                    } else if (data!.automotive) {
                      self.movementType = "🚗"
                    }
                })
            })
            
		} else { l.o.g("Movement type not available") }
	}
	
	func locationManager(
		manager: CLLocationManager,
		didUpdateLocations locations: [CLLocation]) {
			//l.o.g("Location updated")
	}
}
