//
//  IncorrectModalViewController.swift
//  equations
//
//  Created by Sherman Leung on 7/30/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit

class IncorrectModalViewController: UIViewController {

	var errorText:String = "Sorry!"

	@IBAction func dismissModal(sender: AnyObject) {
		self.dismissCurrentPopinControllerAnimated(true)
	}
	@IBOutlet var errorLabel: UILabel!

	override func viewDidLoad() {
		errorLabel.text = errorText
		if (count(errorText) > 10) {
			errorLabel.font = UIFont.systemFontOfSize(18)
		} else {
			errorLabel.font = UIFont.systemFontOfSize(28)
		}
	}
}
