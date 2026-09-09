import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test(arguments: [
        ("", "\n"), ("A", "\n"), ("A\r", "\r\n"),
        ("A\n", "\n"), ("A\r\n", "\n"), ("\r\r", "\r\n"),
        ("e\u{301} 😀\n\r", "\r\n")
    ], ["", "\n", "B\r"])
    func sourceAndGeneratedSeamsHaveDisjointCoordinates(
        example: (source: String, separator: String), following: String
    ) throws
    {
        let fixture = try WritingTestDocument(blocks: [
            WritingCodeFixture.block(example.source, tagged: false),
            WritingCodeFixture.block(following, tagged: true)
        ])
        let projection = try fixture.projection()
        let document = fixture.state.snapshot.document
        let expected = example.source + example.separator + following
        #expect(projection.text.utf16.elementsEqual(expected.utf16))
        #expect(projection.map.utf16Count == expected.utf16.count)
        let indices = Array(projection.text.indices) +
            [projection.text.endIndex]
        let global = Set(indices.map { projection.text.utf16.distance(
                from: projection.text.utf16.startIndex, to: $0
            ) })
        for (span, source) in zip(projection.map.spans,
                                  [example.source, following])
        {
            let native = projection.text as NSString
            #expect(native.substring(with: span.range).utf16
                .elementsEqual(source.utf16))
            for index in Array(source.indices) + [source.endIndex]
            {
                let local = source.utf16.distance(
                    from: source.utf16.startIndex, to: index
                )
                let offset = span.range.location + local
                #expect(global.contains(offset))
                let point = try #require(projection.map.point(
                    offset, in: document
                ))
                #expect(point.blockID == span.blockID)
                #expect(point.utf16Offset.value == local)
                #expect(projection.map.offset(point) == offset)
            }
        }
        let last = try #require(projection.map.spans.last)
        #expect(last.separatorLength == 0)
    }
}
