//
//  CollectionExtensionTests.swift
//  GpxLocationManagerTests
//
//  Created by Nehal Kanetkar on 2018-11-19.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import XCTest

@testable import GpxLocationManager

class CollectionExtensionTests: XCTestCase {
    var subject = [0, 1, 2, 3]

    func testGettingValidElements() {
        XCTAssertEqual(subject.get(at: 0), 0)
        XCTAssertEqual(subject.get(at: 1), 1)
        XCTAssertEqual(subject.get(at: 2), 2)
        XCTAssertEqual(subject.get(at: 3), 3)
    }

    func testGettingInvalidElements() {
        XCTAssertNil(subject.get(at: -1))
        XCTAssertNil(subject.get(at: 4))
        XCTAssertNil(subject.get(at: 100))
    }
}
