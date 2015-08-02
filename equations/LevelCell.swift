//
//  LevelCell.swift
//  equations
//
//  Created by Sherman Leung on 7/30/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit

protocol LevelCellDelegate {
	func displayLevel(level:PFObject)
}

class LevelCell: UITableViewCell{

	var level:PFObject?
	var delegate: LevelCellDelegate?
	
	@IBOutlet var levelButton: UIButton!
	
	@IBAction func displayLevel(sender: AnyObject) {
		delegate?.displayLevel(level!)
	}

	func setupCell() {
		let position = level!["position"] as! String
		levelButton.setTitle(position, forState: UIControlState.Normal)
	}
}
