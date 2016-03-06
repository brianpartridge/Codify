//
//  RangeUtilitiesTests.swift
//  Codify
//
//  Created by Brian Partridge on 3/6/16.
//  Copyright © 2016 Pear Tree Labs. All rights reserved.
//

import Foundation
@testable import Codify
import XCTest


class RangeUtilitiesTests: XCTestCase {
    
    // MARK: - Fixtures
    
    let range = NSMakeRange(0, 10)
    let prefix = NSMakeRange(0, 2)
    let suffix = NSMakeRange(8, 2)
    let middle = NSMakeRange(4, 2)
    
    // MARK: - Tests
    
    func test_rangesBySubtractingRange_equal() {
        let results = rangesBySubtractingRange(range, fromRange: range)
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_rangesBySubtractingRange_prefix() {
        let results = rangesBySubtractingRange(prefix, fromRange: range)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].location, 2)
        XCTAssertEqual(results[0].length, 8)
    }
    
    func test_rangesBySubtractingRange_suffix() {
        let results = rangesBySubtractingRange(suffix, fromRange: range)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].location, 0)
        XCTAssertEqual(results[0].length, 8)
    }
    
    func test_rangesBySubtractingRange_middle() {
        let results = rangesBySubtractingRange(middle, fromRange: range)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].location, 0)
        XCTAssertEqual(results[0].length, 4)
        XCTAssertEqual(results[1].location, 6)
        XCTAssertEqual(results[1].length, 4)
    }
}
