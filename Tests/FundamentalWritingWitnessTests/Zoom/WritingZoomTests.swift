import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite("Writing zoom presentation", .serialized)
struct WritingZoomTests
{
    @Test("zoom steps stay within fifty through two hundred percent")
    func bounds()
    {
        var zoom = WritingZoom(50)
        for percentage in stride(from: 50, through: 200, by: 10)
        {
            #expect(zoom.percentage == percentage)
            zoom = zoom.increased
        }
        #expect(!zoom.canIncrease)
        #expect(zoom.increased == zoom)
        for percentage in stride(from: 200, through: 50, by: -10)
        {
            #expect(zoom.percentage == percentage)
            zoom = zoom.decreased
        }
        #expect(!zoom.canDecrease)
        #expect(zoom.decreased == zoom)
        for invalid in [Int.min, -1, 0, 49, 55, 201, Int.max]
        {
            #expect(WritingZoom(invalid) == WritingZoom())
        }
    }

    @Test("native fonts, indents and spacing scale without changing spelling",
          arguments: [50, 100, 200])
    func typography(_ percentage: Int) throws
    {
        let fixture = try WritingTestDocument(blocks: [
            CanonicalBlockStyle.body.semanticBlock(runs: [
                SemanticRun(text: "Мир e\u{301} 👨‍👩‍👧‍👦")
            ]),
            CanonicalBlockStyle.title.semanticBlock(runs: [
                SemanticRun(text: "Title", traits: [.emphasis])
            ]),
            .listItem(SemanticListItem(kind: .numbered,
                runs: [SemanticRun(text: "Item")])),
            WritingCodeFixture.block("\tlet x = 1\n", tagged: true)
        ])
        let projection = try fixture.projection()
        let zoom = WritingZoom(percentage)
        let shown = try #require(WritingTextPresentation(projection,
                                                         zoom: zoom))
        #expect(shown.text.string.utf16.elementsEqual(projection.text.utf16))
        for (index, size) in [20.0, 34, 20, 18].enumerated()
        {
            let offset = projection.map.spans[index].range.location
            let font = try #require(shown.text.attribute(.font, at: offset,
                effectiveRange: nil) as? NSFont)
            #expect(abs(font.pointSize - size * zoom.scale) < 0.01)
        }
        let listOffset = projection.map.spans[2].range.location
        let style = try #require(shown.text.attribute(.paragraphStyle,
            at: listOffset, effectiveRange: nil) as? NSParagraphStyle)
        let scale = CGFloat(zoom.scale)
        #expect(style.headIndent == 32 * scale)
        #expect(style.paragraphSpacing == 4 * scale)
        let typing = try #require(shown.typingAttributes[.font] as? NSFont)
        #expect(typing.pointSize == 20 * scale)
    }
}
