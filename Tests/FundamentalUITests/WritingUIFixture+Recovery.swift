import AppKit
import Darwin
import XCTest

extension WritingUIFixture
{
    var recoveryDirectory: URL { directory.appending(path: "Recovery") }

    func checkpoints() throws -> [WritingUIRecoveryRecord]
    {
        guard FileManager.default.fileExists(atPath: recoveryDirectory.path)
        else
        {
            return []
        }
        let files = try FileManager.default.contentsOfDirectory(
            at: recoveryDirectory, includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "recovery" }
        return try files.map
        {
            try JSONDecoder().decode(WritingUIRecoveryRecord.self,
                                      from: Data(contentsOf: $0))
        }
    }

    func forceQuit() throws
    {
        let running = NSRunningApplication.runningApplications(
            withBundleIdentifier: identifier
        )
        _ = try XCTUnwrap(running.count == 1 ? true : nil,
                          "Refuse an ambiguous application identity")
        let process = try XCTUnwrap(running.first)
        let actual = try XCTUnwrap(process.bundleURL).resolvingSymlinksInPath()
        let expected = applicationURL.resolvingSymlinksInPath()
        _ = try XCTUnwrap(actual == expected ? true : nil,
                          "Refuse to terminate any other application")
        XCTAssertEqual(Darwin.kill(process.processIdentifier, SIGKILL), 0)
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
