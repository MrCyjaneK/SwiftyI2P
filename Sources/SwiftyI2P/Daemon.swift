import Foundation
import i2pbridge
import Network
import os

public final class Daemon {
    public let version = "2.5.2"

    public let isStarted = OSAllocatedUnfairLock(initialState: false)

    /// A path to i2pd data
    public let dataDir: URL

    /// An i2p configuration. Throws an error is daemon is not started.
    public let configuration: Configuration

    public enum Failure: Error {
        case unknown(String)
        case notStarted
    }

    /// Constructs `Daemon` instance
    /// - Parameter dataDir: An existing path to i2pd data
    public init(dataDir: URL, configuration: Configuration) {
        self.dataDir = dataDir
        self.configuration = configuration
    }

    /// Start i2p.
    public func start() async throws {
        try await withCheckedThrowingContinuation { [dataDir, isStarted] continuation in
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                do {
                    try checkAssets()
                    i2pd_set_data_dir(dataDir.path)

                    let error = String(cString: i2pd_start())
                    guard error == "ok" else {
                        throw Failure.unknown(error)
                    }
                    isStarted.withLock {
                        $0 = true
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Stop i2p
    public func stop() async {
        guard isStarted.withLock({ $0 }) else { return }
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                i2pd_stop()
                continuation.resume()
            }
        }
    }

    private func checkAssets() throws {
        let fm = FileManager.default
        let versionFile = dataDir.appending(path: "assets.ready")
        let confFile = dataDir.appending(path: "i2pd.conf")
        let certificatesDir = dataDir.appending(path: "certificates")
        try? fm.createDirectory(at: dataDir, withIntermediateDirectories: false)
        if let versionData = try? Data(contentsOf: versionFile), String(data: versionData, encoding: .utf8) != version {
            try? fm.removeItem(at: certificatesDir)
            try version.write(to: versionFile, atomically: true, encoding: .utf8)
        }
        try configuration.asString.write(to: confFile, atomically: true, encoding: .utf8)
    }
}
