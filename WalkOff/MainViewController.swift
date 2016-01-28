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
DetailViewControllerDelegate,
CreateInvitationViewControllerDelegate
{
	
	let PresentAuthenticationViewController =
	"PresentAuthenticationViewController"
    
    let menuSection = 0
    let invitationIDsSection = 1
    let gameIDsSection = 2
    
	var localPlayer = GKLocalPlayer.localPlayer()
    
	override func viewDidLoad() {
		super.viewDidLoad()
		GameManager.sharedInstance.delegate = self
		tableView.tableFooterView = UIView(frame: CGRectZero)
        
        Movement.sharedInstance.startCountingSteps()
        Movement.sharedInstance.startReadingMovementType()
	}
    
    func gameManagerMovementUpdated() {
        tableView.reloadSections(NSIndexSet(index: gameIDsSection), withRowAnimation: .None)
    }
    
	func gameManager(newGameCreated gameID: String) {
        print("newGameCreated main VC")
        tableView.reloadSections(NSIndexSet(index: gameIDsSection), withRowAnimation: .Left)
	}
	
	func gameManager(scoreUpdatedForGame gameID: String) {
		print("asd")
        let indexOfGame = GameManager.sharedInstance.gameIDs.indexOf(gameID)
		let indexPath = NSIndexPath(forRow: indexOfGame!, inSection: gameIDsSection)
		let indexPaths = [indexPath]
		
        tableView.reloadRowsAtIndexPaths(
			indexPaths,
			withRowAnimation: .None
        )
	}
    
    func gameManagerInvitationReceived() {
        tableView.reloadSections(NSIndexSet(index: invitationIDsSection), withRowAnimation: .Left)
    }

    
	func gameManagerWasDisconnected() {
        
        let alert = UIAlertController(
            title: "Disconnected",
            message:
            "",
            preferredStyle: UIAlertControllerStyle.Alert
        )
			
        alert.addAction(UIAlertAction(
            title: "Okay",
            style: UIAlertActionStyle.Cancel,
            handler: nil)
        )
        
        self.presentViewController(alert, animated: true, completion: nil)
	}

	override func tableView(
    tableView: UITableView,
    numberOfRowsInSection section: Int)
    -> Int {
	
        var numberOfRows = 0
        
        if section == menuSection {
            numberOfRows = 2
        }
        
        if section == invitationIDsSection {
            numberOfRows = GameManager.sharedInstance.invitations.count
        }
        
        if section == gameIDsSection {
            numberOfRows = GameManager.sharedInstance.gameIDs.count
        }
        
        return numberOfRows
	}
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == invitationIDsSection {
            
            return 72.0
        
        } else {
            
            return 44.0
        }
    }
	
	override func tableView(
    tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
    
        var cell: UITableViewCell
    
        if indexPath.section == menuSection {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("StartNewGameCell")
                    as UITableViewCell!
                
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("StartNewGameCellTest")
                    as UITableViewCell!
            }
            
        } else if indexPath.section == invitationIDsSection {
            cell = tableView.dequeueReusableCellWithIdentifier("InvitationCell")
                as UITableViewCell!
            configureTextForInvitationCell(cell, row: indexPath.row)
        
        } else {
        
            cell = tableView.dequeueReusableCellWithIdentifier("GameCell")
                as UITableViewCell!
            configureTextForGameCell(cell, row: indexPath.row)
        }
        
        return cell
	}
	
    func configureTextForInvitationCell(cell: UITableViewCell, row: Int) {
        let lastIndex = GameManager.sharedInstance.invitations.count - 1
        let invitation = GameManager.sharedInstance.invitations[lastIndex - row]
        let hostAlias = invitation.objectForKey("alias")
        
        let invitationLabel = cell.viewWithTag(1001) as! UILabel
        invitationLabel.text = "👋\(hostAlias!)"
    }
    
    @IBAction func acceptInvitationButton(sender: AnyObject) {
        
        let indexPath = findIndexPathFromSender(sender as! UIButton)
        
        let lastIndex = GameManager.sharedInstance.invitations.count - 1
        let index = lastIndex - indexPath.row
        
        let invitationID = GameManager.sharedInstance.invitations[index].objectForKey("gameID") as! String
        GameManager.sharedInstance.acceptInvitationForGame(invitationID, index: index)
        tableView.reloadSections(NSIndexSet(index: invitationIDsSection), withRowAnimation: .None)
    }
    
    @IBAction func declineInvitationButton(sender: AnyObject) {
        
        let indexPath = findIndexPathFromSender(sender as! UIButton)
        let lastIndex = GameManager.sharedInstance.invitations.count - 1
        let index = lastIndex - indexPath.row
        
        let invitationID = GameManager.sharedInstance.invitations[index].objectForKey("gameID") as! String

        GameManager.sharedInstance.leaveGame(
            invitationID,
            playerID: localPlayer.playerID!
        )
        
        GameManager.sharedInstance.declineInvitation(
            invitationID,
            invitationIndex: index,
            playerID: localPlayer.playerID!
        )
        
        tableView.reloadSections(NSIndexSet(index: invitationIDsSection), withRowAnimation: .None)
    }
    
    func findIndexPathFromSender(button: UIButton) -> NSIndexPath {
        let buttonPosition = button.convertPoint(CGPointZero, toView: tableView)
        return tableView.indexPathForRowAtPoint(buttonPosition)!
    }
    
	func configureTextForGameCell(cell: UITableViewCell, row: Int) {
        let lastIndex = GameManager.sharedInstance.gameIDs.count - 1
        let gameID = GameManager.sharedInstance.gameIDs[lastIndex - row]
		let game = GameManager.sharedInstance.games[gameID]
		let localPlayerID = GameManager.sharedInstance.localPlayer.playerID
		let gameScore = game?.playerData[localPlayerID!]?.score
        let renderedRank = renderPlayerRank((game?.localRank)!)
		
        let gameNameLabel = cell.viewWithTag(1000) as! UILabel
		gameNameLabel.text = "\(gameID)"
		
        
		let scoreAndRankLabel = cell.viewWithTag(1001) as! UILabel
		scoreAndRankLabel.text = "\(gameScore!) \(renderedRank)"
	}
	
    func renderPlayerRank(playerRank: Int) -> String {
        
        var renderedRanked = ""
        
        switch playerRank {
            
        case 1:
            renderedRanked = "🏆"
        case 2:
            renderedRanked = "2️⃣"
        case 3:
            renderedRanked = "3️⃣"
        case 4:
            renderedRanked = "4️⃣"
        case 5:
            renderedRanked = "5⃣️"
        case 6:
            renderedRanked = "6⃣️"
        case 7:
            renderedRanked = "7⃣️"
        case 8:
            renderedRanked = "8⃣️"
        case 9:
            renderedRanked = "9⃣️"
        case 10:
            renderedRanked = "1⃣️0⃣️"
        case 11:
            renderedRanked = "1⃣️1⃣️"
        case 12:
            renderedRanked = "1⃣️2️⃣"
        case 13:
            renderedRanked = "1⃣️3️⃣"
        case 14:
            renderedRanked = "1⃣️4️⃣"
        case 15:
            renderedRanked = "1⃣️5⃣️"
        case 16:
            renderedRanked = "1⃣️6⃣️"
        default:
            renderedRanked = ""
        }
        
        return renderedRanked
    }
    
	override func tableView(
    tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == menuSection {
         
            if indexPath.row == 0 {
                if !GameManager.sharedInstance.gameKitHelper.gameCenterEnabled {
                    l.o.g("No Game Center login.")
                    
                    let alert = UIAlertController(
                        title: "Woops!",
                        message:
                        "Please sign into Game Center to find other players and walk all over them.",
                        preferredStyle: UIAlertControllerStyle.Alert
                    )
                    
                    let gameCenterURL = NSURL(string: "gamecenter:")
                    
                    alert.addAction(
                        UIAlertAction(title: "Open Game Center", style: UIAlertActionStyle.Default) {
                            UIAlertAction in UIApplication.sharedApplication().openURL(gameCenterURL!)
                        }
                    )
                    
                    alert.addAction(
                        UIAlertAction(title: "Maybe later", style: UIAlertActionStyle.Cancel, handler: nil)
                    )
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    //open matchmaker
                    GameManager.sharedInstance.gameKitHelper.findMatch(
                        2,
                        maxPlayers: 2,
                        presentingViewController: self,
                        delegate: GameManager.sharedInstance
                    )
                }
            }
        }
        
        if indexPath.section == invitationIDsSection {
            
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	override func prepareForSegue(
    segue: UIStoryboardSegue,
    sender: AnyObject?) {
        
        let navigationController = segue.destinationViewController as! UINavigationController

        if segue.identifier == "GameDetailSegue" {
            
            let controller = navigationController.topViewController as! DetailViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {

                let lastIndex = GameManager.sharedInstance.gameIDs.count - 1
                let index = lastIndex - indexPath.row
                
                controller.gameID = GameManager.sharedInstance.gameIDs[index]
                controller.delegate = self
            }
        }
        
        if segue.identifier == "CreateInvitationSegue" {
            let controller = navigationController.topViewController as! CreateInvitationViewController
            GameManager.sharedInstance.delegate = controller
            controller.delegate = self
        }
	}
	
	func detailViewControllerDidClose() {
		tableView.reloadData()
		dismissViewControllerAnimated(true, completion: nil)
	}
    
    func createInvitationViewControllerDidCancel() {
        GameManager.sharedInstance.delegate = self
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createInvitationViewControllerDidComplete() {
        GameManager.sharedInstance.delegate = self
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
	
	func detailViewControllerDidLeaveGame(gameID: String) {
		let index = GameManager.sharedInstance.gameIDs.indexOf(gameID)
		GameManager.sharedInstance.gameIDs.removeAtIndex(index!)
		GameManager.sharedInstance.games.removeValueForKey(gameID)
		tableView.reloadData()
		dismissViewControllerAnimated(true, completion: nil)
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}