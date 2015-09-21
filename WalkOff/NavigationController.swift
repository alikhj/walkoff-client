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
		GameCenterAuthorization.sharedInstance.authenticateLocalPlayer()
		super.viewDidLoad()
	}
	
	func showAuthenticationViewController() {
		if let authenticateViewController =
			GameCenterAuthorization.sharedInstance.authenticationViewController {
				l.o.g("Showing Game Center authentication view controller")
				topViewController!.presentViewController(
					authenticateViewController,
					animated: true,
					completion: nil)
		}
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
}
