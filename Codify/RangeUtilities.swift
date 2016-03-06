//
//  RangeUtilities.swift
//  Codify
//
//  Created by Brian Partridge on 3/6/16.
//  Copyright © 2016 Pear Tree Labs. All rights reserved.
//

import Foundation


func rangesBySubtractingRange(subrange: NSRange, fromRange superrange: NSRange) -> [NSRange] {
    precondition(subrange.location >= superrange.location &&
        subrange.location + subrange.length <= superrange.location + superrange.length,
        "Invalid range \(NSStringFromRange(subrange)) in \(NSStringFromRange(superrange))")
    
    let subrangeMax = subrange.location + subrange.length
    let superrangeMax = superrange.location + superrange.length
    let subrangeIsPrefix = subrange.location == superrange.location
    let subrangeIsSuffix = subrangeMax == superrangeMax
    
    if subrangeIsPrefix && subrangeIsSuffix {
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
