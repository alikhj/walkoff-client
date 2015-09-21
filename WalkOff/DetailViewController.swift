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
  var gameID: String?
  var game: Game?


  override func viewDidLoad() {
    game = GameManager.sharedInstance.games[gameID!]!
    game?.delegate = self
    super.viewDidLoad()
    title = gameID!
  }
  
  @IBAction func closeButton(sender: AnyObject) {
    delegate?.detailViewControllerDidClose()
  }

  override func tableView(
    tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return game!.rankedPlayerIDs.count + 2
  }
  
  func game(scoreUpdatedForPlayer playerID: String, previousRank: Int, newRank: Int) {
    tableView.reloadData()
    let previousIndexPath = NSIndexPath(forRow: previousRank + 1, inSection: 0)
    let newIndexPath = NSIndexPath(forRow: newRank + 1, inSection: 0)
    tableView.moveRowAtIndexPath(previousIndexPath, toIndexPath: newIndexPath)
  }

	func playerDataWasUpdated() {
		tableView.reloadData()
  }
  
  override func tableView(
  tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
  -> UITableViewCell {
    var cell: UITableViewCell
    
    if indexPath.row == 0 {
      cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as UITableViewCell!
    
    } else if indexPath.row == game!.rankedPlayerIDs.count + 1 {
      cell = tableView.dequeueReusableCellWithIdentifier("LeaveGameCell") as UITableViewCell!
    
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell") as UITableViewCell!
      configureTextForCell(cell, indexPath: indexPath)
    }
      return cell
  }
  
  func configureTextForCell(cell: UITableViewCell, indexPath: NSIndexPath) {
    let playerID = game!.rankedPlayerIDs[indexPath.row - 1]
    let playerAlias = GameManager.sharedInstance.players[playerID]?.playerAlias
		
		var status = game!.playerData[playerID]!.status!
		
		let activity = status[status.endIndex.predecessor()]
		status.removeAtIndex(status.endIndex.predecessor())
		
    let playerNameLabel = cell.viewWithTag(1000) as! UILabel
		playerNameLabel.text = "\(activity) \(playerAlias!)"
		
    let scoreLabel = cell.viewWithTag(1001) as! UILabel
    scoreLabel.text =
		"\(status) \(game!.playerData[playerID]!.score!)"
    
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let localPlayerID = game!.localPlayerID
    if indexPath.row == game!.rankedPlayerIDs.count + 1 {

      GameManager.sharedInstance.leaveGame(gameID!, playerID: localPlayerID)
			delegate?.detailViewControllerDidLeaveGame(gameID!)

			//dont' forget to check on timed powerups
    }
  }
}

