import AppKit
import FundamentalNativeParagraph
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

@MainActor
struct LayoutProseCompositionTests
{
    @Test func layoutComposesCanonicalSourceAcrossWidths() throws
    {
        let runs = try LayoutProseFixture.runs()
        let session = try LayoutProseFixture.session(runs)
        let state = session.state
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let bytes = try codec.encode(session.document)
        let projection = ProjectionSnapshot(state.snapshot)
        guard case let .prose(_, prose) = projection.firstBlock
        else
        {
            Issue.record("Expected paragraph")
            return
        }
        var generated = false
        var counts: Set<Int> = []
        for size in [18.0, 36]
        {
            let font = try NativeTextKit2Layout().serifFont(
                ofSize: size, weight: .regular
            )
            for width in [90.0, 180, 360]
            {
                let value = try NativeProseComposition(
                    prose, width: width, font: font,
                    language: .english, defaultLanguage: "en_US"
                )
                let paragraph = value.paragraph
                let source = paragraph.collection.source
                #expect(value.prose == prose)
                #expect(source.paragraph.runs == runs)
                #expect(source.source.utf16 == Array(runs.map(\.text)
                    .joined().utf16))
                #expect(source.spans.count == runs.count)
                let lines = paragraph.segments.flatMap(\.lines)
                counts.insert(lines.count)
                var end = 0
                for line in lines
                {
                    #expect(line.sourceRange.lowerBound == end)
                    end = line.sourceRange.upperBound
                    let drawn = try SpacedNativeLine(line)
                    #expect(drawn.advance <= width + 0.000001)
                    for ink in line.shaped.runs.flatMap(\.glyphs)
                        .flatMap(\.sources)
                    {
                        if case let .generated(hyphen) = ink
                        {
                            #expect(hyphen.sourceRange.isEmpty)
                            #expect(hyphen.sourceRange.lowerBound
                                == line.sourceRange.upperBound)
                            generated = true
                        }
                    }
                }
                #expect(end == source.source.utf16.count)
                try LayoutProseCapture.write(
                    paragraph, name: "source-\(Int(size))-\(Int(width))"
                )
                #expect(session.state == state)
                #expect(try codec.encode(session.document) == bytes)
                #expect(!session.isDirty)
                #expect(!session.canUndo && !session.canRedo)
            }
        }
        #expect(generated)
        #expect(counts.count > 1)
        #expect(try codec.decode(bytes) == session.document)
    }
}
