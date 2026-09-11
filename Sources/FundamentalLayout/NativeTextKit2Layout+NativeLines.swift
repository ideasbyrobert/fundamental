import AppKit
import CoreText
import FundamentalNativeWrapping

extension NativeTextKit2Layout
{
    func nativeLines(
        storage: NSTextContentStorage,
        manager: NSTextLayoutManager,
        shaping: NativeWrappingText,
        segments: [NativeSourceSegment],
        defaultFont: LayoutFontIdentity,
        originX: Double,
        originY: Double,
        pointContext: NativeTextPointContext
    ) throws -> [LayoutLine]
    {
        let text = shaping.attributed.string as NSString
        var lines: [LayoutLine] = []
        var failure: LayoutFailure? = nil
        manager.enumerateTextLayoutFragments(
            from: storage.documentRange.location,
            options: [.ensuresLayout, .ensuresExtraLineFragment]
        )
        {
            fragment in
            let base = storage.offset(
                from: storage.documentRange.location,
                to: fragment.rangeInElement.location
            )
            for nativeLine in fragment.textLineFragments
            {
                let local = nativeLine.characterRange
                guard local.location != NSNotFound
                else
                {
                    failure = .invalidNativeSourceRange
                    return false
                }
                let range = NSRange(
                    location: base + local.location,
                    length: local.length
                )
                do
                {
                    lines.append(try line(
                        nativeLine,
                        fragment: fragment,
                        selectionExtent: try selectionExtent(
                            storage: storage, manager: manager,
                            fragment: fragment, line: nativeLine,
                            originX: originX
                        ),
                        range: range,
                        shaping: shaping,
                        text: text,
                        segments: segments,
                        defaultFont: defaultFont,
                        originX: originX,
                        originY: originY,
                        pointContext: pointContext
                    ))
                }
                catch let caught as LayoutFailure
                {
                    failure = caught
                    return false
                }
                catch
                {
                    failure = .invalidNativeSourceRange
                    return false
                }
            }
            return true
        }
        if let failure
        {
            throw failure
        }
        guard !lines.isEmpty
        else
        {
            throw LayoutFailure.missingNativeLine
        }
        return lines
    }
}
