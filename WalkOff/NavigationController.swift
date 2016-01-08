//
//  NavigationController.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

	override func viewDidLoad() {
		
        NSNotificationCenter.defaultCenter().addObserver(self,
			selector: Selector("showAuthenticationViewController"),
			name: PresentAuthenticationViewController,
			object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("showInviteViewController"),
            name: PresentInviteViewController,
            object: nil)
        
		GameManager.sharedInstance.gameKitHelper.authenticateLocalPlayer()
		super.viewDidLoad()
	}
	
	func showAuthenticationViewController() {
		if let authenticateViewController =
			GameManager.sharedInstance.gameKitHelper.authenticationViewController {
				l.o.g("Showing Game Center authentication view controller")
				topViewController!.presentViewController(
					authenticateViewController,
					animated: true,
					completion: nil
                )
		}
	}
    
    func showInviteViewController() {
        if let inviteViewController =
            GameManager.sharedInstance.gameKitHelper.inviteViewController {
                
                GameManager.sharedInstance.gameKitHelper.presentingViewController = topViewController!
                l.o.g("Showing invite view controller")
                topViewController!.presentViewController(
                    inviteViewController,
                    animated: true,
                    completion: nil
                )
        }
    
    }
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
}
