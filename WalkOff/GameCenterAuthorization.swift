//
//  GameCenterAuthorization.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//
//	singleton class that checks for game center authorization

import GameKit

let gameCenterAuthorizationSingleton = GameCenterAuthorization()
let PresentAuthenticationViewController =
	"PresentAuthenticationViewController"

class GameCenterAuthorization: NSObject {
	class var sharedInstance: GameCenterAuthorization {
		return gameCenterAuthorizationSingleton
	}
	
	var authenticationViewController: UIViewController?
	var gameCenterEnabled: Bool
	var lastError: NSError?
	
	override init() {
		gameCenterEnabled = false
		super.init()
	}
	
	func authenticateLocalPlayer() {
		let localPlayer = GKLocalPlayer.localPlayer()
		localPlayer.authenticateHandler = {(viewController, error) in
			self.lastError = error
			l.o.g("Error in localplayer.authenticateHandler: \(error)")
			if viewController != nil {
				self.authenticationViewController = viewController
				NSNotificationCenter.defaultCenter().postNotificationName(
					PresentAuthenticationViewController,
					object: self)
			} else if localPlayer.authenticated {
				self.gameCenterEnabled = true
				l.o.g("Player authorized by Game Center")
                GameManager.sharedInstance.startNetworking()

			} else {
				self.gameCenterEnabled = false
				l.o.g("Player not authorized by Game Center")
			}
		}
	}
}