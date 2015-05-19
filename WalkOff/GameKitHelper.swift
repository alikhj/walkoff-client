//
//  GameKitHelper.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//
//	Contains helper functions for all GameKit activity
//	GameKitHelper is instantiated for each new Game and then discarded
//
//
//	TODO - code to handle invitations

import UIKit
import GameKit

protocol GameKitHelperDelegate {
	func gameKitHelper(newPlayersFound arrayOfPlayersFound: [GKPlayer])
}

class GameKitHelper: NSObject,
GKGameCenterControllerDelegate,
GKMatchmakerViewControllerDelegate {
	
	var delegate: GameKitHelperDelegate?
	var presentingViewController: UIViewController?

	func gameCenterViewControllerDidFinish(
		gameCenterViewController: GKGameCenterViewController!) {
		presentingViewController?.dismissViewControllerAnimated(
			true,
			completion: nil)
	}
	
	//assign the presentingViewController to the object calling this func
	//setup the matchRequest terms and present the matchMakerViewController
	func findMatch(
		minPlayers: Int,
		maxPlayers: Int,
		presentingViewController viewController: UIViewController,
		delegate: GameKitHelperDelegate) {
			
			if !GameCenterAuthorization.sharedInstance.gameCenterEnabled {
				NSLog("Local player not authorized in Game Center")
			}
			
			self.delegate = delegate
			presentingViewController = viewController
			let matchRequest = GKMatchRequest()
			matchRequest.minPlayers = minPlayers
			matchRequest.maxPlayers = maxPlayers
			let matchMakerViewController = GKMatchmakerViewController(
				matchRequest: matchRequest)
			matchMakerViewController.hosted = true
			matchMakerViewController.matchmakerDelegate = self
			presentingViewController?.presentViewController(
				matchMakerViewController,
				animated: false,
				completion: nil)
	}
	
	//send an array to the delegate when all players are found
	func matchmakerViewController(
		viewController: GKMatchmakerViewController!,
		didFindHostedPlayers players: [AnyObject]!) {
			NSLog("Players found")
			let foundPlayers = players as! [GKPlayer]
			delegate?.gameKitHelper(newPlayersFound: foundPlayers)
			presentingViewController?.dismissViewControllerAnimated(
				true,
				completion: nil)
	}
	
	func matchmakerViewControllerWasCancelled(
		viewController: GKMatchmakerViewController!) {
		presentingViewController?.dismissViewControllerAnimated(
			true,
			completion: nil)
	}
	
	func matchmakerViewController(
		viewController: GKMatchmakerViewController!,
		didFailWithError error: NSError!) {
		presentingViewController?.dismissViewControllerAnimated(
			true,
			completion: nil)
		NSLog("Error finding players: \(error.localizedDescription)")
	}
}
