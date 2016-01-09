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
    func createInvitationViewControllerDidClose()
}

class CreateInvitationViewController: UITableViewController {
    
    weak var delegate: CreateInvitationViewControllerDelegate?
    
    let localPlayer = GKLocalPlayer.localPlayer()
    var friendsArray = [GKPlayer]()
    var checked = [Bool]()
    var invitedFriends = [GKPlayer]()

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

    func inviteFriends(friends: [GKPlayer]) {
        
        let matchRequest = GKMatchRequest()
        matchRequest.defaultNumberOfPlayers = 2
        matchRequest.minPlayers = 2
        matchRequest.maxPlayers = 2
        matchRequest.recipients = friends
        
        matchRequest.recipientResponseHandler = { (playerID, response) -> Void in
            print("invitation received: \(response)")
        }
        
        GKMatchmaker.sharedMatchmaker().findPlayersForHostedRequest(
            matchRequest,
            withCompletionHandler: {(players : [GKPlayer]?, error: NSError?) -> Void in
                print("find players")
        })
    }
    
    @IBAction func inviteButton(sender: AnyObject) {
        for index in 0...checked.count - 1 {
            if checked[index] == true {
                invitedFriends.append(friendsArray[index])
            }
        }
        
        inviteFriends(invitedFriends)
    }
    @IBAction func closeButton(sender: AnyObject) {
        delegate?.createInvitationViewControllerDidClose()
    }
}
