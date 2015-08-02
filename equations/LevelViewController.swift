//
//  LevelViewController.swift
//  equations
//
//  Created by Sherman Leung on 7/30/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit



class LevelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LevelCellDelegate {

	var levels:[PFObject] = []
	@IBOutlet var tableView: UITableView!
	var refreshControl = UIRefreshControl()

	override func viewDidLoad() {
		tableView.delegate = self
		tableView.dataSource = self

		onRefresh()
		refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
		tableView.insertSubview(refreshControl, atIndex: 0)

	}

	func onRefresh() {
		let query = PFQuery(className: "Level")
		query.orderByAscending("position")
		query.findObjectsInBackgroundWithBlock { (response: [AnyObject]?, error) -> Void in
			if (error == nil) {
				self.levels = []
				let results = response as! [PFObject]
				for result in results {
					self.levels.append(result)
				}
				self.refreshControl.endRefreshing()
				self.tableView.reloadData()
			} else {
				self.presentErrorModal("Can't fetch levels :( Check your Wi-Fi connection")
				self.refreshControl.endRefreshing()
			}
		}
	}

	func displayLevel(level: PFObject) {
		performSegueWithIdentifier("displayLevel", sender: level)
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var levelCell = tableView.dequeueReusableCellWithIdentifier("levelCell") as! LevelCell
		let level = levels[indexPath.row]
		levelCell.level = level
		levelCell.setupCell()
		levelCell.delegate = self
		return levelCell
	}

	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 120
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return levels.count
	}

	func presentErrorModal(message: String) {
		let errorVC = self.storyboard!.instantiateViewControllerWithIdentifier("incorrectModal") as! IncorrectModalViewController
		errorVC.errorText = message
		errorVC.setPopinTransitionStyle(BKTPopinTransitionStyle.SpringySlide)
		errorVC.setPopinTransitionDirection(BKTPopinTransitionDirection.Top)
		self.presentPopinController(errorVC, fromRect: CGRectMake(self.view.frame.width*0.1, self.view.frame.height*0.2, self.view.frame.width*0.8, self.view.frame.height*0.4), animated: true, completion: nil)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "displayLevel") {
			let level = sender as! PFObject
			var vc = segue.destinationViewController as! GameViewController
			vc.allowedChars = level["allowedChars"] as! String
			vc.requiredChars = level["requiredChars"] as! String
			vc.goalChars = level["goalChars"] as! String
		}
	}
}
