//
//  GameViewController.swift
//  equations
//
//  Created by Sherman Leung on 7/29/15.
//  Copyright (c) 2015 Khan Academy. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UIViewControllerTransitioningDelegate {
	var tileSpacing:CGFloat = 15
	let ScreenHeight = UIScreen.mainScreen().bounds.height

	var allowedTiles:[TileView] = []
	var requiredTiles:[TileView] = []

	var allowedChars:String = "23+4"
	var requiredChars:String = "125+"
	var goalChars:String = "2*4"

	var solutionTiles:[TileView] = []
	var goalTiles:[TileView] = []

	var tileSide:CGFloat = 30
	var startingPanPoint:CGPoint = CGPointZero

	@IBOutlet var allowedArea: UIView!
	@IBOutlet var solutionArea: UIView!
	@IBOutlet var goalArea: UIView!

	override func viewDidLoad() {
		renderBoard()
	}

	func renderBoard() {
		tileSide = ceil(UIScreen.mainScreen().bounds.width * 0.9 / CGFloat(max(count(allowedChars),count(requiredChars))) - tileSpacing)
		tileSpacing = 0.25*tileSide
		allowedTiles = renderArea(allowedArea, chars: allowedChars, required: false, isSolution: false)
		requiredTiles = renderArea(solutionArea, chars: requiredChars, required: true, isSolution: false)
		renderArea(goalArea, chars: goalChars, required: false, isSolution: true)
		adjustGoalTiles(goalTiles, area: goalArea)
	}

	private func renderArea(area: UIView, chars:String, required:Bool, isSolution: Bool) -> [TileView] {
		//get the left margin for first tile
		var tiles:[TileView] = [];
		var xOffset = tileSide*0.75
		if (isSolution) {
			xOffset *= 0.25
		}
		var yOffset = area.frame.origin.y + area.frame.size.height
		if (isSolution) {
			yOffset -= area.frame.size.height/2.0
		}
		//adjust for tile center (instead of the tile's origin)
		for (index, letter) in enumerate(chars) {
			var color = UIColor.tealColor()
			if (required) {
				color = UIColor.grapefruitColor()
			} else if (isSolution) {
				color = UIColor.goldenrodColor()
			}
			let tile = TileView(letter: letter, sideLength: tileSide, required: required, color: color)
			tile.center = CGPointMake(xOffset, yOffset)
			xOffset += (tile.frame.width + tileSpacing)

			if (!isSolution) {
				let panGesture = UIPanGestureRecognizer(target: self, action: "tilePan:")
				tile.addGestureRecognizer(panGesture)

				// pinch recognizer
				let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchTile:")
				tile.addGestureRecognizer(pinchRecognizer)
			}
			if (isSolution) {
				tile.layer.borderColor = UIColor.goldenrodColor().CGColor
			}
			// add views
			self.view.addSubview(tile)
			if (required) {
				solutionTiles.append(tile)
			}
			if (isSolution) {
				goalTiles.append(tile)
			}
			tiles.append(tile)
		}
		return tiles
	}

	func pinchTile(sender: UIPinchGestureRecognizer) {
		if let view = sender.view {
			view.transform = CGAffineTransformScale(view.transform, sender.scale, sender.scale)
			sender.scale = 1.0
		}
	}

	func tilePan(recognizer: UIPanGestureRecognizer) {
		var point = recognizer.locationInView(self.view)
		var tileView = recognizer.view as! TileView
		switch recognizer.state {
		case .Began:
			startingPanPoint = tileView.center
			tileView.pop_addAnimation(createSpringAnimation(1.25), forKey: "springAnimation")
		case .Changed, .Cancelled:
			var dx = recognizer.translationInView(self.view).x
			var dy = recognizer.translationInView(self.view).y
			tileView.center = CGPoint(x: tileView.center.x + dx, y: tileView.center.y + dy)
			recognizer.setTranslation(CGPointZero, inView: self.view)
		case .Ended:
			tileView.pop_addAnimation(createSpringAnimation(1), forKey: "springAnimation")
			if (invalid(tileView)) {
				UIView.animateWithDuration(0.5, animations: { () -> Void in
					tileView.center = self.startingPanPoint
				})
			} else {
				if (contains(solutionTiles, tileView)) {
					solutionTiles.removeAtIndex(find(solutionTiles, tileView)!)
				}
				if (containedWithin(tileView, parent: solutionArea)) {
					var insertIndex = 0
					for (index, tile) in enumerate(solutionTiles) {
						if (tileView.center.x < tile.center.x) {
							insertIndex = index
						}
					}
					solutionTiles.insert(tileView, atIndex: insertIndex)
				}
				adjustTiles(solutionTiles, area: solutionArea)
			}

		case .Failed, .Possible:
			UIView.animateWithDuration(1.0, animations: { () -> Void in
				tileView.center = self.startingPanPoint
			})
		}
	}

	func adjustGoalTiles(tiles:[TileView], area:UIView) {
		let oldTileSide = tiles[0].frame.height
		let newTileSide = ceil(UIScreen.mainScreen().bounds.width * 0.9 / CGFloat(max(count(allowedChars),count(requiredChars))) - tileSpacing)
		let newTileSpacing = newTileSide * 0.25
		let scale = newTileSide/oldTileSide
		for (var i=0; i<tiles.count; i++) {
			tiles[i].pop_addAnimation(createSpringAnimation(scale), forKey: "springAnimation")
			UIView.animateWithDuration(NSTimeInterval.abs(0.2), animations: { () -> Void in
				tiles[i].center.x = CGFloat(i)*(newTileSide+newTileSpacing) +  newTileSide*0.5 + newTileSpacing
				tiles[i].center.y = area.frame.origin.y + area.frame.height/2
			})
		}
	}

	func adjustTiles(tiles:[TileView], area:UIView) {
//		let oldTileSide = tiles[0].frame.height
//		let newTileSide = ceil(UIScreen.mainScreen().bounds.width * 0.9 / CGFloat(tiles.count) - tileSpacing)
//		let newTileSpacing = newTileSide * 0.25
//		let scale = newTileSide/oldTileSide
//		// shift tiles
//		for (var i=0; i<tiles.count; i++) {
//			tiles[i].pop_addAnimation(createSpringAnimation(scale), forKey: "springAnimation")
//			UIView.animateWithDuration(NSTimeInterval.abs(0.2), animations: { () -> Void in
//				tiles[i].center.x = CGFloat(i)*(newTileSide+newTileSpacing) +  newTileSide + newTileSpacing
//				tiles[i].center.y = area.frame.origin.y + area.frame.height/2
//			})
//		}
	}

	func invalid(tile:TileView) -> Bool {
		if (tile.isRequired) {
			return containedWithin(tile, parent: allowedArea) || containedWithin(tile, parent: goalArea)
		} else {
			return containedWithin(tile, parent: goalArea)
		}
	}

	func containedWithin(child: UIView, parent:UIView) -> Bool {
		return CGRectIntersectsRect(child.frame, parent.frame)
	}

	func createSpringAnimation(scale: CGFloat) -> POPSpringAnimation {
		var springAnimation = POPSpringAnimation()
		springAnimation.property = POPAnimatableProperty.propertyWithName(kPOPViewScaleXY) as! POPAnimatableProperty
		springAnimation.springBounciness = 20.0
		springAnimation.velocity = NSValue(CGPoint: CGPointMake(2,2))
		springAnimation.toValue = NSValue(CGPoint: CGPointMake(scale, scale))
		return springAnimation
	}

	@IBAction func back(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil
		)
	}
	@IBAction func checkSolution(sender: AnyObject) {
		// check that all required tiles were used
		for tile in requiredTiles {
			if (!containedWithin(tile, parent: solutionArea)) {
				presentErrorModal("Try to include all required tiles!")
				return
			}
		}

		var solutionTiles:[TileView] = []
		for tile in requiredTiles {
			if (containedWithin(tile, parent: solutionArea)) {
				solutionTiles.append(tile)
			}
		}
		for tile in allowedTiles {
			if (containedWithin(tile, parent: solutionArea)) {
				solutionTiles.append(tile)
			}
		}

		solutionTiles.sort { $0.0.frame.origin.x < $0.1.frame.origin.x }

		var solutionString:String = ""
		for tile in solutionTiles {
			solutionString.append(tile.letter)
		}

		let goalExpression = NSExpression(format: goalChars)
		let expression = NSExpression(format: solutionString)

		var result = expression.expressionValueWithObject(nil, context: nil) as! NSNumber
		var goal = goalExpression.expressionValueWithObject(nil, context: nil) as! NSNumber

		if (goal == result) {
			presentSuccessModal("Woohoo!")
		} else {
			presentErrorModal("Aw man :(")
		}
	}

	func presentSuccessModal(message: String) {
		let successVC = self.storyboard!.instantiateViewControllerWithIdentifier("successModal") as! UIViewController
		successVC.setPopinTransitionStyle(BKTPopinTransitionStyle.SpringySlide)
		successVC.setPopinTransitionDirection(BKTPopinTransitionDirection.Top)
		self.presentPopinController(successVC, fromRect: solutionArea.frame, animated: true, completion: nil)
	}

	func presentErrorModal(message: String) {
		let errorVC = self.storyboard!.instantiateViewControllerWithIdentifier("incorrectModal") as! IncorrectModalViewController
		errorVC.errorText = message
		errorVC.setPopinTransitionStyle(BKTPopinTransitionStyle.SpringySlide)
		errorVC.setPopinTransitionDirection(BKTPopinTransitionDirection.Top)
		self.presentPopinController(errorVC, fromRect: solutionArea.frame, animated: true, completion: nil)
	}

	@IBAction func resetBoard(sender: AnyObject) {
		renderBoard()
	}
}
