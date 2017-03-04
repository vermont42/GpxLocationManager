//
//  UiHelpers.swift
//  RaceRunner
//
//  Created by Joshua Adams on 8/29/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

class UiHelpers {
    class func maskedImageNamed(_ name:String, color:UIColor) -> UIImage {
        let image = UIImage(named: name)
        let rect:CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: image!.size.width, height: image!.size.height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image!.scale)
        let c:CGContext = UIGraphicsGetCurrentContext()!
        image?.draw(in: rect)
        c.setFillColor(color.cgColor)
        c.setBlendMode(CGBlendMode.sourceAtop)
        c.fill(rect)
        let result:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
    
    class func letterPressedText(_ plainText: String) -> NSAttributedString {
        return NSAttributedString(string: plainText, attributes: [NSTextEffectAttributeName: NSTextEffectLetterpressStyle])
    }
}
