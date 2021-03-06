//
//  CreateInvitationViewController.swift
//  WalkOff
//
//  Created by Ali Khawaja on 1/7/16.
//  Copyright © 2016 Candy Snacks. All rights reserved.
//

import Foundation
import UIKit
import GameKit

protocol CreateInvitationViewControllerDelegate: class {
    func createInvitationViewControllerDidCancel()
    func createInvitationViewControllerDidComplete()

}

class CreateInvitationViewController: UITableViewController, GameManagerDelegate {
    
    weak var delegate: CreateInvitationViewControllerDelegate?
    
    let localPlayer = GKLocalPlayer.localPlayer()
    var friendsArray = [GKPlayer]()
    var invitedFriendsArray = [GKPlayer]()
    var checked = [Bool]()
    
    @IBOutlet weak var inviteButton: UIBarButtonItem!


    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRectZero)
        localPlayer.loadFriendPlayersWithCompletionHandler {
            (friends, NSError) -> Void in
            self.friendsArray = friends!
            for _ in 0 ... self.friendsArray.count - 1 {
                self.checked.append(false)
            }
            
            self.tableView.reloadData()
        }
    }
    
    func gameManagerWasDisconnected() {
        print("disconnected")
    }
    
    func gameManager(newGameCreated gameID: String) {
        inviteButton.title = "Done!"
        
        let matchRequest = GKMatchRequest()
        matchRequest.defaultNumberOfPlayers = 2
        matchRequest.minPlayers = 2
        matchRequest.maxPlayers = 2
        matchRequest.recipients = invitedFriendsArray
        matchRequest.recipientResponseHandler = { (playerID, response) -> Void in
            print("invitation received: \(response)")
        }
        
        GKMatchmaker.sharedMatchmaker().findPlayersForHostedRequest(
            matchRequest,
            withCompletionHandler: {(players : [GKPlayer]?, error: NSError?) -> Void in
                print("invitations sent")
        })
        
        delegate?.createInvitationViewControllerDidComplete()

    }
    
    func gameManagerInvitationReceived() {

    }
    
    override func tableView(
    tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! FriendCell
        configureTextForFriendCell(indexPath, cell: cell)
        if checked[indexPath.row] == false {
            cell.accessoryType = .None
        }
        else if checked[indexPath.row] == true {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    func configureTextForFriendCell(indexPath: NSIndexPath, cell: FriendCell) {
        cell.friendAliasLabel.text = friendsArray[indexPath.row].alias
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark
            {
                cell.accessoryType = .None
                checked[indexPath.row] = false
            }
            else
            {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
            }
        }
    }

    @IBAction func inviteButton(sender: AnyObject) {
        
        var invitedFriendsDictionary = [String: String]()
        
        for index in 0...checked.count - 1 {
            if checked[index] == true {
                let invitedFriend = friendsArray[index]
                invitedFriendsArray.append(invitedFriend)
                invitedFriendsDictionary[invitedFriend.playerID!] = invitedFriend.alias!
            }
        }
        
        invitedFriendsDictionary[GKLocalPlayer.localPlayer().playerID!] = GKLocalPlayer.localPlayer().alias
        GameManager.sharedInstance.invitePlayers(invitedFriendsDictionary)
        inviteButton.title = "Waiting..."
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        delegate?.createInvitationViewControllerDidCancel()
    }
}
