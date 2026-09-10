import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func textLines(
        runs: [ProjectedRun],
        width: Double,
        originX: Double,
        originY: Double,
        font: NSFont,
        pointContext: NativeTextPointContext
    ) throws -> [LayoutLine]
    {
        let (attributed, segments) = try attributedSource(
            runs: runs, font: font
        )
        guard attributed.length > 0
        else
        {
            return [try emptyLine(
                font: font, width: width, originX: originX, originY: originY,
                pointContext: pointContext
            )]
        }
        let storage = NSTextContentStorage()
        let manager = NSTextLayoutManager()
        let container = NSTextContainer(size: CGSize(
            width: width,
            height: .greatestFiniteMagnitude
        ))
        container.lineFragmentPadding = 0
        storage.addTextLayoutManager(manager)
        manager.textContainer = container
        storage.attributedString = attributed
        manager.ensureLayout(for: storage.documentRange)
        return try nativeLines(
            storage: storage, manager: manager, attributed: attributed,
            segments: segments, defaultFont: fontIdentity(font as CTFont),
            originX: originX, originY: originY, pointContext: pointContext
        )
    }
}
