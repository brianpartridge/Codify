//
//  RangeUtilities.swift
//  Codify
//
//  Created by Brian Partridge on 3/6/16.
//  Copyright © 2016 Pear Tree Labs. All rights reserved.
//

import Foundation


extension NSRange: Equatable {}


public func ==(lhs: NSRange, rhs: NSRange) -> Bool {
    return lhs.location == rhs.location && lhs.length == rhs.length
}


func rangesBySubtractingRange(subrange: NSRange, fromRange superrange: NSRange) -> [NSRange] {
    precondition(subrange.location >= superrange.location &&
        subrange.location + subrange.length <= superrange.location + superrange.length,
        "Invalid range \(NSStringFromRange(subrange)) in \(NSStringFromRange(superrange))")
    
    guard subrange.length != 0 else { return [superrange] }
    
    let subrangeMax = subrange.location + subrange.length
    let superrangeMax = superrange.location + superrange.length
    let subrangeIsPrefix = subrange.location == superrange.location
    let subrangeIsSuffix = subrangeMax == superrangeMax
    
    if subrange == superrange {
        return []
    } else if subrangeIsPrefix {
        return [NSMakeRange(subrangeMax, superrangeMax - subrangeMax)]
    } else if subrangeIsSuffix {
        return [NSMakeRange(superrange.location, subrange.location)]
    } else {
        let prefixRange = NSMakeRange(superrange.location, subrange.location)
        let suffixRange = NSMakeRange(subrangeMax, superrangeMax - subrangeMax)
        return [prefixRange, suffixRange]
    }
}
