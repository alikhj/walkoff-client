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
  
    var indexPathOfLocalPlayer: NSIndexPath {
        
        return NSIndexPath(
            forRow: game!.rankedPlayerIDs.indexOf(game!.localPlayerID)!,
            inSection: players
        )
    }
    
    var challengeWeaponAvailable: Bool {
        
        if game.challengeWeapons.count > 0 {
            return true
        
        } else {
            return false
        }
    }
    
    var chaseWeaponAvailable: Bool {
        
        if game.chaseWeapons.count > 0 {
            return true
            
        } else {
            return false
        }
    }
    
    override func viewDidLoad() {
        game = GameManager.sharedInstance.games[gameID]!
        game.delegate = self
        super.viewDidLoad()
        title = gameID
    }
    
    @IBAction func fireChaseButton(sender: AnyObject) {
        game.fireChaseWeapon()
    }
    
    @IBAction func fireChallengeButton(sender: AnyObject) {
        game.fireChallengeWeapon()
    }
  
    func game(scoreUpdatedForPlayer playerID: String, previousRank: Int, newRank: Int) {
        tableView.reloadData()
    
        let previousIndexPath = NSIndexPath(forRow: previousRank, inSection: players)
        let newIndexPath = NSIndexPath(forRow: newRank, inSection: players)

        tableView.moveRowAtIndexPath(previousIndexPath, toIndexPath: newIndexPath)
    }

    func game(itemUpdatedForPlayer playerID: String) {
        var indexPath = NSIndexPath()
        let rankIndex = game!.rankedPlayerIDs.indexOf(playerID)!
        indexPath = NSIndexPath(forRow: rankIndex, inSection: players)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
  
    func gamePowerUpOnStandby() {
        tableView.reloadSections(NSIndexSet(index: standbyPowerUps), withRowAnimation: .Top)
    }
	
    func game(powerUpStarted standbyPowerUpIndex: Int) {
        let indexPath = NSIndexPath(forRow: standbyPowerUpIndex, inSection: 0)
		tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
		tableView.reloadRowsAtIndexPaths([indexPathOfLocalPlayer], withRowAnimation: .None)
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
    
    func gameWeaponUpdated() {
        tableView.reloadRowsAtIndexPaths([indexPathOfLocalPlayer], withRowAnimation: .None)
    }
    
    func gamePlayerLeft() {
        tableView.reloadData()
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
            
            if indexPath == indexPathOfLocalPlayer &&
            (chaseWeaponAvailable || challengeWeaponAvailable)
            {
                if challengeWeaponAvailable && chaseWeaponAvailable {
                    cell = tableView.dequeueReusableCellWithIdentifier("ChaseChallengeCell") as! PlayerCell
                    
                    configureTitleForFireChallengeWeaponButton(cell as! PlayerCell, indexPath: indexPath)
                    configureTextForChallengeWeaponsLabel(cell as! PlayerCell)
                    
                    configureTitleForFireChaseWeaponButton(cell as! PlayerCell, indexPath: indexPath)
                    configureTextForChaseWeaponsLabel(cell as! PlayerCell)
                
                } else if challengeWeaponAvailable {
                    cell = tableView.dequeueReusableCellWithIdentifier("ChallengeCell") as! PlayerCell
                    configureTitleForFireChallengeWeaponButton(cell as! PlayerCell, indexPath: indexPath)
                    configureTextForChallengeWeaponsLabel(cell as! PlayerCell)
                
                } else {
                    cell = tableView.dequeueReusableCellWithIdentifier("ChaseCell") as! PlayerCell
                    configureTitleForFireChaseWeaponButton(cell as! PlayerCell, indexPath: indexPath)
                    configureTextForChaseWeaponsLabel(cell as! PlayerCell)

                }
                
            } else {
                
                cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell") as! PlayerCell
            }
            
            configureTextForPlayerCell(cell as! PlayerCell, indexPath: indexPath)

        }
    
        if indexPath.section == menu {
            cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
            configureTextForMenuCell(cell as! MenuCell, indexPath: indexPath)
        }

        return cell
    }
    
    func configureTitleForFireChaseWeaponButton(cell: PlayerCell, indexPath: NSIndexPath) {
        
        var indicator: String
        var description: String
        
        if indexPath.row == 0 {
            cell.fireChaseWeaponButton.enabled = false
            indicator = ""
            description = "👍 Keep it up!"
            
        } else {
            cell.fireChaseWeaponButton.enabled = true
            indicator = "👆"
            description = game.chaseWeapons.first!.description
        }
        
        let fireChaseWeaponButtonTitle = "\(indicator) \(description)"
        cell.fireChaseWeaponButton.setTitle(fireChaseWeaponButtonTitle, forState: UIControlState.Normal)

    }
    
    func configureTitleForFireChallengeWeaponButton(cell: PlayerCell, indexPath: NSIndexPath) {
        
        var indicator: String
        var description: String
        
        if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
            cell.fireChallengeWeaponButton.enabled = false
            indicator = ""
            description = "👎 Get moving!"
        
        } else {
            cell.fireChallengeWeaponButton.enabled = true
            indicator = "👇"
            description = game.challengeWeapons.first!.description
        }
        
        let fireChallengeWeaponButtonTitle = "\(indicator) \(description)"
        cell.fireChallengeWeaponButton.setTitle(fireChallengeWeaponButtonTitle, forState: UIControlState.Normal)
    }
    
    func configureTextForChaseWeaponsLabel(cell: PlayerCell) {
        var chaseWeaponsLabelText = ""
        for chaseWeapon in game.chaseWeapons {
            chaseWeaponsLabelText += getChase(chaseWeapon.chaseID).name
        }
    
        cell.chaseWeaponsLabel.text = chaseWeaponsLabelText
    }
    
    func configureTextForChallengeWeaponsLabel(cell: PlayerCell) {
        var challengeWeaponsLabelText = ""
        for challengeWeapon in game.challengeWeapons {
            challengeWeaponsLabelText += getChallenge(challengeWeapon.challengeID).name
        }
        
        cell.challengeWeaponsLabel.text = challengeWeaponsLabelText
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

  
    func configureTextForMenuCell(cell: MenuCell, indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cell.menuItemLabel.text = "Leave Game"
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight: CGFloat
        
        if indexPath == indexPathOfLocalPlayer &&
        (chaseWeaponAvailable || challengeWeaponAvailable)
        {
            if chaseWeaponAvailable && challengeWeaponAvailable {
                rowHeight = 132
            
            } else {
                rowHeight = 88
            }
        
        } else {
            rowHeight = 44
        }
        
        return rowHeight
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

