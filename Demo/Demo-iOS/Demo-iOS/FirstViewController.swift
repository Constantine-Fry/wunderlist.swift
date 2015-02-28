//
//  FirstViewController.swift
//  Demo-iOS
//
//  Created by Constantine Fry on 13/01/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import UIKit
import WunderlistTouch

class FirstViewController: UITableViewController {
    
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    var session: Session!
    
    var lists: [List]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = Session.sharedSession()
        if session.isAuthorized() {
            self.fetchLists()
        }
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        session.authorize(self) {
            (result, error) -> Void in
            if result {
                self.fetchLists()
            }
        }
    }
    
    func fetchLists() {
        let listTask = self.session.lists.getLists() {
            (lists, error) -> Void in
            self.lists = lists
            self.tableView.reloadData()
        }
        listTask.start()
    }
    
    //MARK: - Table View
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        let list = lists?[indexPath.row]
        cell.textLabel?.text = list?.title
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if lists != nil {
            return lists!.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}

