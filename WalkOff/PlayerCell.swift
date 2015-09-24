//
//  PlayerCell.swift
//  WalkOff
//
//  Created by Ali Khawaja on 9/23/15.
//  Copyright © 2015 Candy Snacks. All rights reserved.
//

import Foundation
import UIKit

class PlayerCell: UITableViewCell {
  
  @IBOutlet var playerLabel: UILabel!
  @IBOutlet var scoreLabel: UILabel!
  @IBOutlet weak var tipsLabel: UILabel!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    playerLabel.font = UIFont.systemFontOfSize(17.0)
  
  }
}
