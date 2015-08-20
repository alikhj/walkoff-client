//
//  ViewController.swift
//  WalkOff
//
//  Created by Ali Khawaja on 5/12/15.
//  Copyright (c) 2015 Candy Snacks. All rights reserved.
//

import UIKit
import GameKit

class MainViewController:
UITableViewController,
GameManagerDelegate,
DetailViewControllerDelegate {
	
	let PresentAuthenticationViewController =
	"PresentAuthenticationViewController"

	var allGames = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		GameManager.sharedInstance.delegate = self
		GameManager.sharedInstance.startNetworking()
		//only show required rows
		tableView.tableFooterView = UIView(frame: CGRectZero)
		//the row with startNewGame cell is row 0, so...
		//insert dummy index so array matches tableview rows
		allGames.append("")
	}
	
	func gameManager(newGameCreated gameID: String) {
		allGames.append(gameID)
//		let indexPath = NSIndexPath(forRow: allGames.count, inSection: 0)
//		let indexPaths = [indexPath]
		//this should be insertRowAtIndexPath
        tableView.reloadData()
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
    
    func gameManagerWasDisconnected() {
        var alert = UIAlertController(title: "Disconnected",
            message:
            "",
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(
            title: "Okay",
            style: UIAlertActionStyle.Cancel,
            handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

	override func tableView(
		tableView: UITableView,
		numberOfRowsInSection section: Int)
		-> Int {
		return allGames.count
	}
	
	override func tableView(
		tableView: UITableView,
		cellForRowAtIndexPath indexPath: NSIndexPath)
		-> UITableViewCell {
			var cell: UITableViewCell
			if indexPath.row == 0 {
				cell = tableView.dequeueReusableCellWithIdentifier("StartNewGameCell")
					as! UITableViewCell
			} else {
				cell = tableView.dequeueReusableCellWithIdentifier("GameCell")
					as! UITableViewCell
				configureTextForCell(cell, row: indexPath.row)
			}
			return cell
	}
	
	func configureTextForCell(cell: UITableViewCell, row: Int) {
		let gameID = allGames[row]
		let game = GameManager.sharedInstance.allGames[gameID]
		let localPlayerID = GameManager.sharedInstance.localPlayer.playerID
		let gameScore = game?.allPlayers[localPlayerID]?.score
		let playerRank = game?.localRank
		
		let gameNameLabel = cell.viewWithTag(1000) as! UILabel
		gameNameLabel.text = "\(gameID)"
		
		let scoreAndRankLabel = cell.viewWithTag(1001) as! UILabel
		scoreAndRankLabel.text = "\(gameScore!) (\(playerRank!))"
	}
	
	override func tableView(
		tableView: UITableView,
		didSelectRowAtIndexPath indexPath: NSIndexPath) {
			if indexPath.row == 0 {
				if !GameCenterAuthorization.sharedInstance.gameCenterEnabled {
					l.o.g("No Game Center login.")
					var alert = UIAlertController(title: "Woops!",
						message:
						"Please sign into Game Center to find other players and walk all over them.",
						preferredStyle: UIAlertControllerStyle.Alert)
					let gameCenterURL = NSURL(string: "gamecenter:")
					alert.addAction(UIAlertAction(
						title: "Open Game Center",
						style: UIAlertActionStyle.Default) {
						UIAlertAction in
						UIApplication.sharedApplication().openURL(gameCenterURL!) })
					alert.addAction(UIAlertAction(
						title: "Maybe later",
						style: UIAlertActionStyle.Cancel,
						handler: nil))
					self.presentViewController(alert, animated: true, completion: nil)
				} else {
					//open matchmaker
					GameManager.sharedInstance.gameKitHelper.findMatch(
						2,
						maxPlayers: 16,
						presentingViewController: self,
						delegate: GameManager.sharedInstance)
				}
			} else {
				//segue to games

			}
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
    override func prepareForSegue(
        segue: UIStoryboardSegue,
        sender: AnyObject?) {
            let navigationController = segue.destinationViewController as!
                UINavigationController
            let controller = navigationController.topViewController as!
                DetailViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.gameID = allGames[indexPath.row]
                controller.delegate = self
            }
    }
    
    func detailViewControllerDidClose() {
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}