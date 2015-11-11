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
  
    var menuItems = ["Leave game", "TEST – Add 5 steps"]
  
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
		
		localPlayerIndexPath = NSIndexPath(
            forRow: game!.rankedPlayerIDs.indexOf(game!.localPlayerID)!,
            inSection: players
        )
	
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }
  
    func game(scoreUpdatedForPlayer playerID: String, previousRank: Int, newRank: Int) {
        
        tableView.reloadData()
    
        let previousIndexPath = NSIndexPath(forRow: previousRank, inSection: players)
        let newIndexPath = NSIndexPath(forRow: newRank, inSection: players)

        tableView.moveRowAtIndexPath(previousIndexPath, toIndexPath: newIndexPath)
    }

    func game(itemUpdatedForPlayer playerID: String) {
        let indexPath = NSIndexPath(forRow: game!.rankedPlayerIDs.indexOf(playerID)!, inSection: players)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        tableView.reloadData()
    }
  
    func gamePowerUpOnStandby() {
        tableView.reloadSections(NSIndexSet(index: standbyPowerUps), withRowAnimation: .Top)
    }
	
    func game(powerUpStarted standbyPowerUpIndex: Int) {
        let indexPath = NSIndexPath(forRow: standbyPowerUpIndex, inSection: 0)
		tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
		tableView.reloadRowsAtIndexPaths([localPlayerIndexPath], withRowAnimation: .None)
	}
	
    func game(challengeStartedWithID challengeID: Challenge) {
		let challenge = getChallenge(challengeID)
		
		let alert = UIAlertController(title: challenge.name, message: challenge.description, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Got it", style: .Default, handler: nil))
		
		self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func game(chaseStartedWithID chaseID: Chase) {
        let chase = getChase(chaseID)
        
        let alert = UIAlertController(title: chase.name, message: chase.description, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func gameOffenseOnStandby() {
        
    }
	
    override func tableView(
    tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
    
        var cell = UITableViewCell()
    
        if indexPath.section == standbyPowerUps {
            cell = tableView.dequeueReusableCellWithIdentifier("StandbyPowerUpCell") as! StandbyPowerUpCell
            configureTextForStandbyPowerUpCell(cell as! StandbyPowerUpCell, indexPath: indexPath)
        }
        
        if indexPath.section == players {
            cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell") as! PlayerCell
            configureTextForPlayerCell(cell as! PlayerCell, indexPath: indexPath)
        }
    
        if indexPath.section == menu {
            cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
            configureTextForMenuCell(cell as! MenuCell, indexPath: indexPath)
        }

        return cell
    }
	
    func configureTextForStandbyPowerUpCell(cell: StandbyPowerUpCell, indexPath: NSIndexPath) {
		
        let powerUp = getPowerUp(game.standbyPowerUpIDs[indexPath.row])
        cell.powerUpDescriptionLabel.text = powerUp.description
        cell.powerUpNameLabel.text = powerUp.name
	}
	
    func configureTextForPlayerCell(cell: PlayerCell, indexPath: NSIndexPath) {
        
        let playerID = game!.rankedPlayerIDs[indexPath.row]
        var playerAlias = GameManager.sharedInstance.players[playerID]?.playerAlias
		
		let activity = game!.playerData[playerID]!.activity
		
		let powerUps = game!.playerData[playerID]!.powerUps.joinWithSeparator("")
		let powerDowns = game!.playerData[playerID]!.powerDowns.joinWithSeparator("")
		let challenges = game!.playerData[playerID]!.challenges.joinWithSeparator("")
        let chases = game!.playerData[playerID]!.chases.joinWithSeparator("")
		
        if indexPath.row == game!.rankedPlayerIDs.indexOf(game!.localPlayerID)! {
            playerAlias = "Me"
            cell.playerLabel.font = UIFont.boldSystemFontOfSize(17.0)
        } else {
            cell.playerLabel.font = UIFont.systemFontOfSize(17.0)
        }

		//if challenge is A, place after activity
		//if challenge is B, place before activity
		
		cell.playerLabel.text = "\(challenges)\(activity)\(powerDowns)\(chases) \(playerAlias!)"
		
        cell.scoreLabel.text =
        "\(powerUps) \(game!.playerData[playerID]!.score!)"
    }
  
    func configureTextForMenuCell(cell: MenuCell, indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cell.menuItemLabel.text = "Leave Game"
        }
        
        if indexPath.row == 1 {
            cell.menuItemLabel.text = "TEST – add 5 steps"
        }
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
            
            if (indexPath.row == 1) {
                game!.addTestSteps()
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

