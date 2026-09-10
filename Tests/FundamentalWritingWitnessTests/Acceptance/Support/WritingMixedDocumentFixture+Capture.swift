import AppKit
import Testing

@testable import FundamentalMacOracle

extension WritingMixedDocumentFixture
{
    static func captureReader(
        _ controller: MacReaderWindowController, name: String
    ) throws
    {
        let window = try #require(controller.window)
        let view = try #require(window.contentView)
        view.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        let bitmap = try #require(view.bitmapImageRepForCachingDisplay(
            in: view.bounds
        ))
        view.cacheDisplay(in: view.bounds, to: bitmap)
        try WritingWindowCapture.export(bitmap, name: name)
    }
}
