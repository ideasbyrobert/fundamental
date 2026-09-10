import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderDocumentFixture
{
    static func capture(
        _ controller: MacReaderWindowController, name: String
    ) throws
    {
        let window = try #require(controller.window)
        let root = try #require(window.contentView)
        root.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        let bitmap = try #require(root.bitmapImageRepForCachingDisplay(
            in: root.bounds
        ))
        root.cacheDisplay(in: root.bounds, to: bitmap)
        #expect(bitmap.pixelsWide > 0)
        #expect(bitmap.pixelsHigh > 0)
        guard let path = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_READER_INPUT_CAPTURE_DIR"
        ]
        else
        {
            return
        }
        let directory = URL(fileURLWithPath: path, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )
        let bytes = try #require(bitmap.representation(
            using: .png, properties: [:]
        ))
        try bytes.write(to: directory.appending(path: name + ".png"),
                        options: .atomic)
    }
}
