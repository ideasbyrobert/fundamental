import Foundation
import Testing

@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test(arguments: [("A\r", 9), ("A\r\nB", 8)])
    func CRLFSelectionHandoffsRespectDirectionAndWholePairs(
        example: (source: String, start: Int)
    ) throws
    {
        let fixture = try WritingCodeFixture.document(example.source,
                                                     tagged: false)
        let projection = try fixture.projection()
        for (old, length, proposed, width, expected, resultWidth) in [
            (2, 0, 1, 0, 0, 0), (0, 0, 1, 0, 2, 0),
            (2, 0, 1, 1, 0, 2), (0, 0, 0, 1, 0, 2),
            (0, 2, 1, 1, 2, 0), (0, 2, 0, 1, 0, 0),
            (0, 2, 1, 0, 0, 0), (0, 0, 0, 2, 0, 2)
        ]
        {
            let result = projection.nativeSelection(NSRange(
                location: example.start + proposed, length: width
            ), from: NSRange(location: example.start + old, length: length))
            #expect(result == NSRange(location: example.start + expected,
                                      length: resultWidth))
        }
        for range in [NSRange(location: -1, length: 0),
                      NSRange(location: 0, length: -1),
                      NSRange(location: Int.max, length: 1),
                      NSRange(location: projection.map.utf16Count + 1,
                              length: 0)]
        {
            #expect(projection.nativeSelection(
                range, from: projection.selection
            ) == nil)
        }
    }
}
