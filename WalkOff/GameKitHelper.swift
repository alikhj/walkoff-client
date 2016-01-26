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

import Foundation
import UIKit
import GameKit

protocol GameKitHelperDelegate {
	func gameKitHelper(newPlayersFound arrayOfPlayersFound: [GKPlayer])
}

let PresentAuthenticationViewController =
"PresentAuthenticationViewController"
let PresentInviteViewController =
"PresentInviteViewController"


class GameKitHelper:
NSObject,
GKMatchmakerViewControllerDelegate,
GKLocalPlayerListener
{
    
    var authenticationViewController: UIViewController?
    var inviteViewController: GKMatchmakerViewController!
    
    var gameCenterEnabled: Bool
    var lastError: NSError?
    
	var delegate: GameKitHelperDelegate?
	var presentingViewController: UIViewController?
	var multiplayerMatch: GKMatch?
	var multiplayerMatchStarted: Bool
    var invite: GKInvite?
    
	override init() {
		multiplayerMatchStarted = false
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
                
                localPlayer.registerListener(self)
                
                self.gameCenterEnabled = true
                GameManager.sharedInstance.startNetworking()
                
                l.o.g("Player authorized by Game Center")
            } else {
                self.gameCenterEnabled = false
                l.o.g("Player not authorized by Game Center")
            }
        }
    }

    func player(player: GKPlayer, didAcceptInvite invite: GKInvite) {
        
        print("didAcceptInvite")
        GameManager.sharedInstance.checkForInvitations()
  
    }

    
    //assign the presentingViewController to the object calling this func
	//setup the matchRequest terms and present the matchMakerViewController
	func findMatch(
		minPlayers: Int,
		maxPlayers: Int,
		presentingViewController viewController: UIViewController,
		delegate: GameKitHelperDelegate) {
			if !GameManager.sharedInstance.gameKitHelper.gameCenterEnabled {
				print("local player not auth")
				return
			}
			multiplayerMatchStarted = false
			multiplayerMatch = nil
            
			self.delegate = delegate
            
			presentingViewController = viewController
			
            let matchRequest = GKMatchRequest()
			matchRequest.minPlayers = minPlayers
			matchRequest.maxPlayers = maxPlayers
			
            let matchMakerViewController = GKMatchmakerViewController(
				matchRequest: matchRequest)!
			
            matchMakerViewController.hosted = true
			matchMakerViewController.matchmakerDelegate = self
            
            presentingViewController?.presentViewController(
				matchMakerViewController,
				animated: false,
				completion: nil)
	}
            
	//send an array to the delegate when all players are found
	func matchmakerViewController(
		viewController: GKMatchmakerViewController,
		didFindHostedPlayers players: [GKPlayer]) {
			
            l.o.g("Players found")
			let foundPlayers = players 
			delegate?.gameKitHelper(newPlayersFound: foundPlayers)
			presentingViewController?.dismissViewControllerAnimated(
				true,
				completion: nil)
	}
	
	func matchmakerViewControllerWasCancelled(
		viewController: GKMatchmakerViewController) {
			l.o.g("matchmakerViewController was cancelled")
            
            presentingViewController?.dismissViewControllerAnimated(
				true,
				completion: nil)
	}
	
	func matchmakerViewController(
		viewController: GKMatchmakerViewController,
		didFailWithError error: NSError) {
		presentingViewController?.dismissViewControllerAnimated(
			true,
			completion: nil)
		l.o.g("Error finding players: \(error.localizedDescription)")
	}
    

}
