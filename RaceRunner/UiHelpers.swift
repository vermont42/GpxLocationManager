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
    class func maskedImageNamed(name:String, color:UIColor) -> UIImage {
        let image = UIImage(named: name)
        let rect:CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: image!.size.width, height: image!.size.height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image!.scale)
        let c:CGContextRef = UIGraphicsGetCurrentContext()!
        image?.drawInRect(rect)
        CGContextSetFillColorWithColor(c, color.CGColor)
        CGContextSetBlendMode(c, CGBlendMode.SourceAtop)
        CGContextFillRect(c, rect)
        let result:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    class func letterPressedText(plainText: String) -> NSAttributedString {
        return NSAttributedString(string: plainText, attributes: [NSTextEffectAttributeName: NSTextEffectLetterpressStyle])
    }
}