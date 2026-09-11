import AppKit
import FundamentalNativeParagraph
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@MainActor
struct LayoutProseAttributesTests
{
    @Test func projectedTraitsResolveThroughExistingLayoutFonts() throws
    {
        let traits: [Set<SemanticInlineTrait>] = [
            [], [.strong], [.emphasis], [.inlineCode], [.underline],
            [.strikethrough], [.superscript], [.subscriptText]
        ]
        let runs = traits.map { LayoutFixture.direct("word ", traits: $0) }
        let prose = LayoutProseFixture.prose(runs)
        let layout = NativeTextKit2Layout()
        for size in [18.0, 36]
        {
            let font = try layout.serifFont(ofSize: size, weight: .regular)
            let result = try NativeProseComposition(
                prose, width: 2_000, font: font,
                language: .english, defaultLanguage: "en_US"
            ).paragraph
            let line = try #require(result.segments.first?.lines.first)
            let display = line.shaped.measurement.attributed
            let (original, _) = try layout.attributedSource(
                runs: prose.runs, font: font
            )
            #expect(display.isEqual(to: original.attributedSubstring(
                from: NSRange(location: 0, length: original.length - 1)
            )))
            let bold = try #require(display.attribute(
                .font, at: 5, effectiveRange: nil
            ) as? NSFont)
            let code = try #require(display.attribute(
                .font, at: 15, effectiveRange: nil
            ) as? NSFont)
            #expect(bold.fontDescriptor.symbolicTraits.contains(.bold))
            #expect(code.fontDescriptor.symbolicTraits.contains(.monoSpace))
            #expect(display.attribute(
                .baselineOffset, at: 30, effectiveRange: nil
            ) as? Double == size * 0.3)
            #expect(display.attribute(
                .baselineOffset, at: 35, effectiveRange: nil
            ) as? Double == -size * 0.2)
            try LayoutProseCapture.write(result, name: "traits-\(Int(size))")
        }
    }

    @Test func emptyOriginalRunsSurviveEmptyComposition() throws
    {
        for count in [0, 2]
        {
            let runs = Array(
                repeating: LayoutFixture.direct("", traits: [.strong]),
                count: count
            )
            let result = try NativeProseComposition(
                LayoutProseFixture.prose(runs), width: 80,
                font: .systemFont(ofSize: 18),
                language: .english, defaultLanguage: "en_US"
            ).paragraph
            #expect(result.collection.source.paragraph.runs == runs)
            #expect(result.collection.source.spans.count == count)
            #expect(result.segments.flatMap(\.lines).count == 1)
            try LayoutProseCapture.write(result, name: "empty-\(count)")
        }
    }
}
