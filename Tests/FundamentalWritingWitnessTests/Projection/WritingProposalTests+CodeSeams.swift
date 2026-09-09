import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test(arguments: [false, true])
    func codeEndingInCRKeepsItsEndpointOutsideGeneratedTerminator(
        tagged: Bool
    ) throws
    {
        let fixture = try WritingCodeFixture.document("A\r", tagged: tagged)
        let projection = try fixture.projection()
        let document = fixture.state.snapshot.document
        let spans = projection.map.spans
        let end = NSMaxRange(spans[1].range)
        #expect(projection.text.utf16.elementsEqual(
            "Before\nA\r\r\nAfter".utf16
        ))
        let native = projection.text as NSString
        #expect(native.substring(with: spans[1].range) == "A\r")
        let boundaries = projection.text.indices.map
        {
            projection.text.utf16.distance(from: projection.text.utf16
                .startIndex, to: $0)
        }
        #expect(boundaries.contains(end))
        #expect(spans[2].range.location == end + 2)
        let endpoint = try #require(projection.map.point(end, in: document))
        #expect(endpoint.blockID == spans[1].blockID)
        #expect(endpoint.utf16Offset.value == 2)
        #expect(projection.map.point(end + 1, in: document) == nil)
    }
}
