//
//  l.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/21/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit

let LSingleton = l()

class l: NSObject {
	class var o: l{
		return LSingleton
	}
	
	func g(text: String) {
		NSLog(text)
		print(text)
	}
	
}

