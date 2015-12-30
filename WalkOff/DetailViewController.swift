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
  
    var indexPathLocalPlayer: NSIndexPath {
        
        var forRow: Int
        
        if game!.chaseWeaponIDs.count > 0 {
            forRow = game!.rankedPlayerIDs.indexOf(game!.localPlayerID)! + 1
        } else {
            forRow = game!.rankedPlayerIDs.indexOf(game!.localPlayerID)!
        }
        
        return NSIndexPath(
            forRow: forRow,
            inSection: players
        )
    }
    
    var chaseWeaponIndexPath: NSIndexPath?
    var challengeWeaponIndexPath: NSIndexPath?
  
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

    func game(itemUpdatedForPlayer playerID: String) {
        var indexPath = NSIndexPath()
        var rankIndex = game!.rankedPlayerIDs.indexOf(playerID)!
        
        if game.challengeWeaponIDs.count > 0 {
            rankIndex++
        }
        
        if game.chaseWeaponIDs.count > 0 {
            rankIndex++
        }
                
        print("test: \(playerID) \(rankIndex)")
        
        indexPath = NSIndexPath(forRow: rankIndex, inSection: players)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
  
    func gamePowerUpOnStandby() {
        tableView.reloadSections(NSIndexSet(index: standbyPowerUps), withRowAnimation: .Top)
    }
	
    func game(powerUpStarted standbyPowerUpIndex: Int) {
        let indexPath = NSIndexPath(forRow: standbyPowerUpIndex, inSection: 0)
		tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
		tableView.reloadRowsAtIndexPaths([indexPathLocalPlayer], withRowAnimation: .None)
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
    
    func gameWeaponLoaded() {
        tableView.reloadData()
    }
    
    func gameChaseWeaponFired() {
        if game.chaseWeaponIDs.count > 0 {
            tableView.reloadRowsAtIndexPaths([chaseWeaponIndexPath!], withRowAnimation: .None)
        
        } else {
            tableView.reloadSections(NSIndexSet(index: players), withRowAnimation: .None)
        }

    }
	
    func gameChallengeWeaponFired() {
        if game.challengeWeaponIDs.count > 0 {
            tableView.reloadRowsAtIndexPaths([challengeWeaponIndexPath!], withRowAnimation: .None)
            
        } else {
            tableView.reloadSections(NSIndexSet(index: players), withRowAnimation: .None)
        }
        
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
            
            //for all rows up to localplayer row
            if indexPath.row < indexPathLocalPlayer.row {
                cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell") as! PlayerCell
                configureTextForPlayerCell(cell as! PlayerCell, indexPath: indexPath)
                
                //if there is a chaseWeapon and it's the row before localplayer
                if indexPath.row == indexPathLocalPlayer.row - 1 && game.chaseWeaponIDs.count > 0 {
                    
                    chaseWeaponIndexPath = indexPath
                    cell = tableView.dequeueReusableCellWithIdentifier("WeaponCell") as! WeaponCell
                    configureTextForChaseWeaponCell(cell as! WeaponCell, indexPath: indexPath)
                }
                
            } else {
                
                //for all rows after localplayer row
                if indexPath.row == indexPathLocalPlayer.row + 1 && game.challengeWeaponIDs.count > 0 {
                    
                    challengeWeaponIndexPath = indexPath
                    cell = tableView.dequeueReusableCellWithIdentifier("WeaponCell") as! WeaponCell
                    configureTextForChallengeWeaponCell(cell as! WeaponCell, indexPath: indexPath)
                
                } else {
                    var index = indexPath.row
                    
                    if game.chaseWeaponIDs.count > 0 {
                        index--
                    }
                    
                    if game.challengeWeaponIDs.count > 0 && indexPath.row > indexPathLocalPlayer.row {
                        index--
                    }
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell") as! PlayerCell
                    
                    let newIndexPath = NSIndexPath(
                        forRow: index,
                        inSection: indexPath.section
                    )
                    
                    configureTextForPlayerCell(cell as! PlayerCell, indexPath: newIndexPath)
                }
            }
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
        var playerLabelText = ""
        
        if game.playerData[playerID]!.inGame == true {
            
            if ((GameManager.sharedInstance.players[playerID]?.connected) == true) {
                
                var movementType: String
                if game.playerData[playerID]!.score == 0 {
                    movementType = "🏁"
                } else {
                    movementType = GameManager.sharedInstance.players[playerID]!.movementType!
                }
                
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
                
                cell.playerLabel.textColor = UIColor.blackColor()
                playerLabelText = "\(challenges)\(movementType)\(powerDowns)\(chases) \(playerAlias!)"
                cell.scoreLabel.textColor = UIColor.blackColor()
                cell.scoreLabel.text = "\(powerUps) \(game!.playerData[playerID]!.score!)"
                
            } else {
                cell.playerLabel.textColor = UIColor.grayColor()
                cell.scoreLabel.textColor = UIColor.grayColor()
                playerLabelText = "⌛ \(playerAlias!)"
            }
        
        } else {
            
            playerLabelText = "💀 \(playerAlias!)"
        }
    
        cell.playerLabel.text = playerLabelText
        cell.scoreLabel.text = "\(game!.playerData[playerID]!.score!)"
    }
    
    func configureTextForChaseWeaponCell(cell: WeaponCell, indexPath: NSIndexPath) {
        var indicator: String
        var weapons = ""
        if indexPath.row == 0 || indexPath.row == tableView.numberOfRowsInSection(players) - 1 {
            indicator = "🚫"
            cell.userInteractionEnabled = false
        } else {
            indicator = "👆"
            cell.userInteractionEnabled = true
        }
        
        for chaseID in game.chaseWeaponIDs {
            weapons += getChase(chaseID).name
        }
        
        cell.weaponLabel.text = "\(indicator) \(weapons)"
    }
    
    func configureTextForChallengeWeaponCell(cell: WeaponCell, indexPath: NSIndexPath) {
        var indicator: String
        var weapons = ""
        if indexPath.row == 0 || indexPath.row == tableView.numberOfRowsInSection(players) - 1 {
            indicator = "🚫"
            cell.userInteractionEnabled = false
        } else {
            indicator = "👇"
            cell.userInteractionEnabled = true
        }
        
        for challengeID in game.challengeWeaponIDs {
            weapons += getChallenge(challengeID).name
        }
        
        cell.weaponLabel.text = "\(indicator) \(weapons)"
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
    
        if indexPath.section == standbyPowerUps {
            let powerUpID = game.standbyPowerUpIDs[indexPath.row]
            game.startPowerUp(powerUpID, standbyPowerUpIndex: indexPath.row)
        }
    
        if indexPath.section == menu {
            if indexPath.row == 0 {
                GameManager.sharedInstance.leaveGame(gameID!, playerID: game!.localPlayerID)
                delegate?.detailViewControllerDidLeaveGame(gameID!)
            }
        }
        
        if indexPath == chaseWeaponIndexPath {
            game.fireChaseWeapon()
        }
        
        if indexPath == challengeWeaponIndexPath {
            game.fireChallengeWeapon()
        }
    }
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 3
	}
	
    override func tableView(
        tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
            
            var numberOfRows = 0
            
            if section == standbyPowerUps {
                numberOfRows = game.standbyPowerUpIDs.count
            }
            
            if section == players {
                numberOfRows = game.rankedPlayerIDs.count
                
                if game.chaseWeaponIDs.count > 0 {
                    numberOfRows++
                }
                
                if game.challengeWeaponIDs.count > 0 {
                    numberOfRows++
                }
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

