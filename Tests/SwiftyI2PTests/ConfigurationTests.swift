//
//  File.swift
//
//
//  Created by Vladimir Solomenchuk on 6/7/24.
//

import Foundation
@testable import SwiftyI2P
import Testing

struct ConfigurationTests {
    @Test func asString() {
        var config = Configuration()
        config.set(key: "a", value: "1")
        config.set(key: "b.a", value: "hii")
        config.set(key: "a.a", value: 1)
        config.set(key: "a.b", value: false)
        config.set(key: "b", value: "2")
        #expect(
            config.asString == """
            a = 1
            b = 2
            [a]
            a = 1
            b = false
            [b]
            a = hii
            """
        )
    }
}
