import AppKit
import Testing

@testable import FundamentalWritingWitness

@MainActor
struct WritingWindowCapture
{
    static func capture(_ window: WritingTestWindow) throws
        -> NSBitmapImageRep
    {
        let layout = try #require(window.view.textLayoutManager)
        let content = try #require(layout.textContentManager)
        layout.ensureLayout(for: content.documentRange)
        let root = try #require(window.controller.documentWindow.contentView)
        root.layoutSubtreeIfNeeded()
        window.controller.documentWindow.displayIfNeeded()
        let bitmap = try #require(root.bitmapImageRepForCachingDisplay(
            in: root.bounds
        ))
        root.cacheDisplay(in: root.bounds, to: bitmap)
        return bitmap
    }

    static func export(_ bitmap: NSBitmapImageRep, name: String) throws
    {
        guard let path = ProcessInfo.processInfo.environment[
            "FUNDAMENTAL_WRITING_CAPTURE_DIR"
        ]
        else
        {
            return
        }
        let directory = URL(fileURLWithPath: path, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )
        let bytes = try #require(bitmap.representation(using: .png,
                                                       properties: [:]))
        try bytes.write(to: directory.appending(path: name + ".png"),
                         options: .atomic)
    }

    static func contrastingSamples(_ bitmap: NSBitmapImageRep) throws -> Int
    {
        let background = try #require(bitmap.colorAt(x: 2, y: 2)?
            .usingColorSpace(.deviceRGB))
        var count = 0
        for y in stride(from: 0, to: bitmap.pixelsHigh, by: 4)
        {
            for x in stride(from: 100, to: bitmap.pixelsWide - 100, by: 4)
            {
                let pixel = try #require(bitmap.colorAt(x: x, y: y)?
                    .usingColorSpace(.deviceRGB))
                let difference = abs(pixel.redComponent -
                    background.redComponent) + abs(pixel.greenComponent -
                    background.greenComponent) + abs(pixel.blueComponent -
                    background.blueComponent)
                if difference > 0.3
                {
                    count += 1
                }
            }
        }
        return count
    }
}
