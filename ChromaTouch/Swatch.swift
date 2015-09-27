//
//  Swatch.swift
//  ChromaTouch
//
//  Created by SIMON_NON_ADMIN on 27/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class Swatch: UIControl
{
    var previousForce: CGFloat = 0
    
    var hsl: HSL
    {
        didSet
        {
            updateColor()
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesMoved(touches, withEvent: event)

        guard let touch = touches.first else
        {
            return
        }
        
        let touchLocation = touch.locationInView(self)
        let force = touch.force
        let maximumPossibleForce = touch.maximumPossibleForce
 
        let forceDelta = previousForce - force
        previousForce = force
        
        if forceDelta < 0.25
        {
            let normalisedXPosition = touchLocation.x / frame.width
            let normalisedYPosition = touchLocation.y / frame.height
            let normalisedZPosition = force / maximumPossibleForce
            
            hsl = HSL(hue: normalisedXPosition,
                saturation: normalisedYPosition,
                lightness: normalisedZPosition)
            
            sendActionsForControlEvents(.ValueChanged)
        }
    }

    required init(hsl: HSL)
    {
        self.hsl = hsl

        super.init(frame: CGRectZero)
        
        updateColor()
    }
    
    func updateColor()
    {
        backgroundColor = UIColor(hue: hsl.hue,
            saturation: hsl.saturation,
            brightness: hsl.lightness,
            alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize
    {
        let side = min(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        
        return CGSize(width: side, height: side)
    }
}