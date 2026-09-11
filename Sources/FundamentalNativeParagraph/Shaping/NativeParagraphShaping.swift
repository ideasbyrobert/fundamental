import CoreText
import Foundation
import FundamentalNativeWrapping
import FundamentalParagraph

@MainActor
enum NativeParagraphShaping
{
    static func measure(
        _ attributed: NSAttributedString, inlineOffset: Double
    ) throws -> NativeWrappingLine
    {
        guard let source = NativeWrappingText(attributed),
              let measured = source.line(
                  in: 0..<attributed.length, inlineOffset: inlineOffset
              )
        else
        {
            throw ExplicitShapingFailure.nativeMeasurement
        }
        return measured
    }

    static func runs<Source>(
        _ measured: NativeWrappingLine, displayLength: Int,
        sources: (Range<Int>) throws -> [Source]
    ) throws -> [MappedNativeRun<Source>]
    {
        guard let native = measured.native
        else
        {
            return []
        }
        return try (CTLineGetGlyphRuns(native) as! [CTRun]).map
        {
            try MappedNativeRun(
                $0, displayLength: displayLength, sources: sources
            )
        }
    }
}
