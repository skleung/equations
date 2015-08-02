//
//  TileView.swift
//  equations
//
//  Created by Sherman Leung on 7/29/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit

class TileView: UICollectionViewCell {
	var letter: Character

	//3
	var isRequired:Bool = false
	var isMatched: Bool = false

	//4 this should never be called
	required init(coder aDecoder:NSCoder) {
		fatalError("use init(letter:, sideLength:")

	}
	//5 create a new tile for a given letter
	init(letter:Character, sideLength:CGFloat, required: Bool, color: UIColor) {
		self.letter = letter
		super.init(frame: CGRectZero)
		var image = UIImage(named: "tile")!
		isRequired = required
		self.layer.cornerRadius = 10
		self.layer.borderWidth = 5
		if (required) {
			self.layer.borderColor = color.CGColor
		} else {
			self.layer.borderColor = color.CGColor
		}

		let scale = sideLength / image.size.width
		self.frame = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)

		self.backgroundColor = UIColor.ivoryColor()

		//adds the character label
		let letterLabel = UILabel(frame: self.bounds)
		letterLabel.textAlignment = NSTextAlignment.Center
		letterLabel.textColor = color
		letterLabel.backgroundColor = UIColor.clearColor()
		letterLabel.text = String(letter).uppercaseString
		letterLabel.font = UIFont(name: "Verdana-Bold", size: 78.0*scale)
		self.addSubview(letterLabel)
	}

}
