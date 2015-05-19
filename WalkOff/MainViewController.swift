//
//  ViewController.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit

class MainViewController:
UITableViewController,
GameManagerDelegate {
	
	var allGames = [String]()
	//dont forget to make this a delegate to GameManager
	override func viewDidLoad() {
		super.viewDidLoad()
		//only show required rows
		tableView.tableFooterView = UIView(frame: CGRectZero)
		//create new game row is row 0, so...
		//insert dummy index so array matches tableview rows
		allGames.append("")
	}

	func gameManager(newGameCreated gameID: String) {
		let rowForNewGame = GameManager.sharedInstance.allGames.count + 1
		let indexPath = NSIndexPath(forRow: rowForNewGame, inSection: 0)
		let indexPaths = [indexPath]
		allGames.append(gameID)
		tableView.insertRowsAtIndexPaths(
			indexPaths,
			withRowAnimation: .Automatic)
	}
	
	func gameManager(scoreUpdatedForGame gameID: String) {
		let indexOfGame = find(allGames, gameID)
		let indexPath = NSIndexPath(forRow: indexOfGame!, inSection: 0)
		let indexPaths = [indexPath]
		tableView.reloadRowsAtIndexPaths(
			indexPaths,
			withRowAnimation: .Automatic)
		//mkae this an optional function that passed gameID,
		//so you can only update the specific cell, and not the whole table
	}

	override func tableView(
		tableView: UITableView,
		numberOfRowsInSection section: Int)
		-> Int {
		return GameManager.sharedInstance.allGames.count + 1
	}
	
	override func tableView(
		tableView: UITableView,
		cellForRowAtIndexPath indexPath: NSIndexPath)
		-> UITableViewCell {
			var cell: UITableViewCell
			if indexPath.row == 0 {
				cell = tableView.dequeueReusableCellWithIdentifier("NewGameCell") as! UITableViewCell
			} else {
				cell = tableView.dequeueReusableCellWithIdentifier("GameCell") as! UITableViewCell
				configureTextForCell(cell, row: indexPath.row)
			}
			return cell
	}
	
	override func tableView(
		tableView: UITableView,
		didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
			//segue code
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
			
	}
	
	func configureTextForCell(cell: UITableViewCell, row: Int) {
		let gameID = allGames[row]
		let game = GameManager.sharedInstance.allGames[gameID]
		let localPlayerID = GameManager.sharedInstance.localPlayer.playerID
		let gameScore = game?.allPlayers[localPlayerID]?.score
		let playerRank = game?.localRank
		
		let gameNameLabel = cell.viewWithTag(1000) as! UILabel
		let gameNameLabelText = "\(gameID)"
		
		let scoreAndRankLabel = cell.viewWithTag(1001) as! UILabel
		let scoreAndRankLabelText = "\(gameScore) (\(playerRank))"
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
