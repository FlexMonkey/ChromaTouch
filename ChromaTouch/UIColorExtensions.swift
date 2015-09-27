//
//  UIColorExtensions.swift
//  ChromaTouch
//
//  Created by SIMON_NON_ADMIN on 27/09/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

extension UIColor
{
    
    func getRGBA() -> [Float]
    {
        func zeroIfDodgy(value: Float) ->Float
        {
            return isnan(value) || isinf(value) ? 0 : value
        }
        
        if CGColorGetNumberOfComponents(self.CGColor) == 4
        {
            let colorRef = CGColorGetComponents(self.CGColor);
            
            let redComponent = (zeroIfDodgy(Float(colorRef[0])))
            let greenComponent = (zeroIfDodgy(Float(colorRef[1])))
            let blueComponent = (zeroIfDodgy(Float(colorRef[2])))
            let alphaComponent = (zeroIfDodgy(Float(colorRef[3])))
            
            return [redComponent, greenComponent, blueComponent, alphaComponent]
        }
        else if CGColorGetNumberOfComponents(self.CGColor) == 2
        {
            let colorRef = CGColorGetComponents(self.CGColor);
            
            let greyComponent = (zeroIfDodgy(Float(colorRef[0])))
            let alphaComponent = (zeroIfDodgy(Float(colorRef[1])))
            
            return [greyComponent, greyComponent, greyComponent, alphaComponent]
        }
        else
        {
            return [0,0,0,0]
        }
    }

    
    func getHex() -> String
    {
        let rgb = self.getRGBA()
        
        let red = NSString(format: "%02X", Int(rgb[0] * 255))
        let green = NSString(format: "%02X", Int(rgb[1] * 255))
        let blue = NSString(format: "%02X", Int(rgb[2] * 255))
        
        return (red as String) + (green as String) + (blue as String)
    }
}
