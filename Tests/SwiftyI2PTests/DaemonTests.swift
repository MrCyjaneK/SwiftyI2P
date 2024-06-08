@testable import SwiftyI2P
import XCTest
import Network

final class DaemonTests: XCTestCase {
    var dataDir: URL!
    var daemon: Daemon!

    override func setUp() async throws {
        try await super.setUp()
        dataDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appending(component: UUID().uuidString)
        daemon = Daemon(dataDir: dataDir, configuration: Configuration())
    }

    override func tearDown() async throws {
        await daemon.stop()
        try await super.tearDown()
    }

    func testStart() async throws {
        let e = expectation(description: "test")
        Task {
            do {
                try await daemon.start()
            } catch {
                XCTFail("unexpected error \(error)")
            }
            e.fulfill()
        }

        await fulfillment(of: [e], timeout: 120)
    }

    func testSocksProxy() async throws {
        try await daemon.start()
        switch daemon.configuration.socksProxy {
        case let .hostPort(host: host, port: port):
            XCTAssertEqual("127.0.0.1", host)
            XCTAssertEqual(4447, port)
        default:
            XCTFail("untested")
        }
    }

    func testSetSocksProxy() async throws {
        var configuration = Configuration()
        configuration.socksProxy = .hostPort(host: "127.0.0.1", port: 4449)
        daemon = Daemon(dataDir: dataDir, configuration: configuration)
        try await daemon.start()
        XCTAssertEqual(daemon.configuration.socksProxy, .hostPort(host: "127.0.0.1", port: 4449))
    }
    
    func testSetPortAndConnect() async throws {
        var configuration = Configuration()
          configuration.socksProxy = .hostPort(host: "127.0.0.1", port: 4449)
        daemon = Daemon(dataDir: dataDir, configuration: configuration)
        try await daemon.start()
        let config = URLSessionConfiguration.default
        var proxy = ProxyConfiguration(socksv5Proxy: try XCTUnwrap(daemon.configuration.socksProxy))
        proxy.matchDomains = ["i2p"]
        config.proxyConfigurations = [proxy]
        let session = URLSession(configuration: config)
        let url = try XCTUnwrap(URL(string: "http://nytzrhrjjfsutowojvxi7hphesskpqqr65wpistz6wa7cpajhp7a.b32.i2p"))
        try await Task.sleep(for: .seconds(60))
        let (_, response) = try await session.data(for: URLRequest(url: url))
        XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
    }
}
