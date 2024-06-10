//
//  Configuration.swift
//
//
//  Created by Vladimir Solomenchuk on 6/7/24.
//

import Foundation
import i2pbridge
import Network

public struct Configuration: Sendable {
    private var content = [String: Sendable]()

    public init() {}

    /// Set a value for the key
    /// - Parameters:
    ///   - key: A key.
    ///   - value: A value.
    public mutating func set(key: String, value: Sendable) {
        content[key] = value
    }

    /// Get a value by the key.
    /// - Parameter key: A key. Section should be delemited with '.', e.g, httpproxy.enable.
    /// - Returns: a corresponging value. Value is undefined if daemon is not started.
    public func get(key: String) throws -> UInt16 {
        i2pd_get_uint16_option(key)
    }

    /// Get a value by the key.
    /// - Parameter key: A key. Section should be delemited with '.', e.g, httpproxy.enable.
    /// - Returns: a corresponging value. Value is undefined if daemon is not started.
    public func get(key: String) throws -> String {
        String(cString: i2pd_get_string_option(key))
    }

    var asString: String {
        var currentSection = ""
        var lines = [String]()
        let sortedKeys = content.keys.sorted { a, b in
            let aS = a.firstIndex(of: ".") != nil
            let bS = b.firstIndex(of: ".") != nil
            if aS, bS {
                return a < b
            } else if aS {
                return false
            } else if bS {
                return true
            } else {
                return a < b
            }
        }
        for compoundKey in sortedKeys {
            let keySection = compoundKey.components(separatedBy: ".")
            let key: String
            let section: String
            if keySection.count == 1 {
                section = ""
                key = keySection[0]
            } else {
                section = keySection[0]
                key = keySection[1]
            }
            if section != currentSection {
                lines.append("[\(section)]")
                currentSection = section
            }

            lines.append("\(key) = \(content[compoundKey]!)")
        }

        return lines.joined(separator: "\n")
    }
}

public extension Configuration {
    var socksProxy: NWEndpoint? {
        get {
            do {
                let host: String = try get(key: "socksproxy.address")
                let port: UInt16 = try get(key: "socksproxy.port")

                guard let port = NWEndpoint.Port(rawValue: port) else {
                    return nil
                }

                return NWEndpoint.hostPort(
                    host: .init(host),
                    port: port
                )
            } catch {
                return nil
            }
        }
        set {
            switch newValue {
            case let .hostPort(host: host, port: port):
                set(key: "socksproxy.address", value: host.debugDescription)
                set(key: "socksproxy.port", value: Int32(port.rawValue))
            default:
                assertionFailure("only hostPort is supported")
            }
        }
    }
}
