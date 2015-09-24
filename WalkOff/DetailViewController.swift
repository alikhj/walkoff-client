//
//  DetailViewController.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate: class {
  func detailViewControllerDidClose()
	func detailViewControllerDidLeaveGame(gameID: String)
}

class DetailViewController:
UITableViewController,
GameDelegate {

  weak var delegate: DetailViewControllerDelegate?
  var gameID: String!
  var game: Game!
  
  var timer = NSTimer()
  
  var menuItems = ["Leave game"]
  
  let standbyPowerUps = 0
  let players = 1
  let menu = 2
  
  var localPlayerIndexPath: NSIndexPath!
  var localPlayerCellHeight: CGFloat = 44.0
  var localPlayerCell: PlayerCell!
  var powerDownLabel: UILabel!
  
  override func viewDidLoad() {
    game = GameManager.sharedInstance.games[gameID]!
    game.delegate = self
    super.viewDidLoad()
    title = gameID
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0

  }
  
  func game(scoreUpdatedForPlayer playerID: String, previousRank: Int, newRank: Int) {
    tableView.reloadData()
    
    let previousIndexPath = NSIndexPath(forRow: previousRank, inSection: players)
    let newIndexPath = NSIndexPath(forRow: newRank, inSection: players)

    tableView.moveRowAtIndexPath(previousIndexPath, toIndexPath: newIndexPath)
  }

	func playerDataWasUpdated() {
    tableView.reloadData()
  }
  
  func powerUpOnStandby() {
    tableView.reloadSections(
      NSIndexSet(index: standbyPowerUps),
      withRowAnimation: .Top)
  }
  
  func powerDownStarted() {
    
    localPlayerCell = tableView.cellForRowAtIndexPath(localPlayerIndexPath) as! PlayerCell
    localPlayerCell.tipsLabel.text = "k"

      tableView.reloadData()
  }
  
  func powerDownStopped() {

    powerDownLabel.removeFromSuperview()
    tableView.reloadRowsAtIndexPaths([localPlayerIndexPath], withRowAnimation: .Top)

  }
  
  override func tableView(
  tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
  -> UITableViewCell {
    
    var cell = UITableViewCell()
    
    if indexPath.section == standbyPowerUps {
      cell = tableView.dequeueReusableCellWithIdentifier("StandbyPowerUpCell") as UITableViewCell!
      configureTextForstandbyPowerUpCell(cell, indexPath: indexPath)
    }
    
    if indexPath.section == players {
      cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell") as UITableViewCell!
      configureTextForPlayerCell(cell as! PlayerCell, indexPath: indexPath)
    }
    
    if indexPath.section == menu {
      cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as UITableViewCell!
      configureTextForMenuCell(cell, indexPath: indexPath)
    }

    return cell
  }
	
	func configureTextForstandbyPowerUpCell(cell: UITableViewCell, indexPath: NSIndexPath) {
		
		let descriptionLabel = cell.viewWithTag(1002) as! UILabel
		let powerUpLabel = cell.viewWithTag(1003) as! UILabel
		
		if game.standbyPowerUpIDs.count > 0 {
			let powerUp = getPowerUp(game.standbyPowerUpIDs[indexPath.row])
			descriptionLabel.text = powerUp.description
			powerUpLabel.text = powerUp.name
			
		} else {
			descriptionLabel.textColor = UIColor.lightGrayColor()
			descriptionLabel.text = "Keep moving!"
			powerUpLabel.text = "⌛️"
		}
	}
	
  func configureTextForPlayerCell(cell: PlayerCell, indexPath: NSIndexPath) {
    let playerID = game!.rankedPlayerIDs[indexPath.row]
    var playerAlias = GameManager.sharedInstance.players[playerID]?.playerAlias
		
		var status = game!.playerData[playerID]!.status!
		let activity = status[status.startIndex]
		status.removeAtIndex(status.startIndex)
    
    if playerID == game.localPlayerID {
      playerAlias = "Me"
      cell.playerLabel.font = UIFont.boldSystemFontOfSize(17.0)
      localPlayerIndexPath = indexPath
    }

		cell.playerLabel.text = "\(activity) \(playerAlias!)"
		
    cell.scoreLabel.text =
		"\(status) \(game!.playerData[playerID]!.score!)"
    
  }
  
  func configureTextForMenuCell(cell: UITableViewCell, indexPath: NSIndexPath) {
    
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if (indexPath.section == standbyPowerUps) {
      let powerUpID = game.standbyPowerUpIDs[indexPath.row]
      game.startPowerUp(powerUpID, standbyPowerUpIndex: indexPath.row)
    }
    
    if (indexPath.section == menu) {
      if (indexPath.row == 0) {
        GameManager.sharedInstance.leaveGame(gameID!, playerID: game!.localPlayerID)
        delegate?.detailViewControllerDidLeaveGame(gameID!)
      }
    }
  }
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 3
	}
	
	override func tableView(
		tableView: UITableView,
		numberOfRowsInSection section: Int
		) -> Int {
			
			var numberOfRows: Int!
			
			if section == standbyPowerUps {
				numberOfRows = game.standbyPowerUpIDs.count
			}
			
			if section == players {
				numberOfRows = game.rankedPlayerIDs.count
			}
			
			if section == menu {
				numberOfRows = menuItems.count
			}
			
			return numberOfRows
	}
	
	@IBAction func closeButton(sender: AnyObject) {
		
		delegate?.detailViewControllerDidClose()
	}
	
}

