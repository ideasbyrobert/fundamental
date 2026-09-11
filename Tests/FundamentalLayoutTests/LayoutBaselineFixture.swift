import AppKit
import CoreText
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalNativeWrapping

@MainActor
struct LayoutBaselineFixture
{
    let name: String
    let attributed: NSAttributedString
    let line: CTLine
    let runs: [LayoutGlyphRun]
    let baseline: LayoutPoint
    let publicLines: [LayoutLine]

    init(
        name: String, font: NSFont, traits: Set<SemanticInlineTrait>,
        baseline: LayoutPoint
    ) throws
    {
        let source = [
            LayoutFixture.direct("AVATAR "),
            LayoutFixture.direct("office e\u{301}", traits: traits),
            try LayoutFixture.scoped(" конец")
        ]
        let projection = try LayoutFixture.projection([
            .paragraph(SemanticParagraph(runs: source))
        ])
        guard case let .prose(block, prose) = projection.firstBlock
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let native = NativeTextKit2Layout()
        let (attributed, segments) = try native.attributedSource(
            runs: prose.runs, font: font
        )
        let wrapping = try #require(NativeWrappingText(attributed))
        let measured = try #require(wrapping.line(
            in: 0..<attributed.length, inlineOffset: 0
        ))
        self.name = name
        self.attributed = attributed
        line = try #require(measured.native)
        self.baseline = baseline
        runs = try native.glyphRuns(
            measured, baseline: baseline, segments: segments,
            text: attributed.string as NSString
        )
        publicLines = try native.proseLines(
            prose, source: block, width: 240, originY: baseline.y
        )
    }

    static var traits: [(String, Set<SemanticInlineTrait>)]
    {
        [
            ("plain", []),
            ("raised", [.superscript]),
            ("lowered", [.subscriptText]),
            ("raised-strong", [.superscript, .strong]),
            ("lowered-emphasis", [.subscriptText, .emphasis]),
            ("raised-decorated", [.superscript, .underline, .strikethrough])
        ]
    }
}
