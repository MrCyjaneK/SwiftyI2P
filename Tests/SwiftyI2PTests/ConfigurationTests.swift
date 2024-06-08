//
//  File.swift
//  
//
//  Created by Vladimir Solomenchuk on 6/7/24.
//

import Foundation
@testable import SwiftyI2P
import XCTest

final class ConfigurationTests: XCTestCase {
    func testAsString() {
        var config = Configuration()
        config.set(key: "abra", value: "kadabra")
        config.set(key: "b.a", value: "hii")
        config.set(key: "a.a", value: 1)
        config.set(key: "a.b", value: false)
        XCTAssertEqual(config.asString, """
abra = kadabra
[a]
a = 1
b = false
[b]
a = hii
""")
    }
}
