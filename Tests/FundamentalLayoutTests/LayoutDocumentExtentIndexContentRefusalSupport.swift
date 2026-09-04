import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    func expectContentRefusal(
        capacity: LayoutExtentIndexCapacity
    ) throws
    {
        let projection = try LayoutFixture.projection([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("Original")
            ]))
        ])
        let other = try LayoutFixture.projection([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("Counterfeit")
            ]))
        ])
        let prose: ProjectedProse
        switch other.firstBlock
        {
        case let .prose(_, value):
            prose = value
        case .code, .table:
            Issue.record("Expected projected prose")
            return
        }
        let block = ProjectedBlock.prose(
            source: projection.firstBlock.source,
            prose: prose
        )
        let request = try LayoutFixture.request(width: 320)
        let measurement = try NativeTextKit2Layout().measure(
            block,
            parameters: request.parameters
        )
        #expect(measurement.source == projection.firstBlock.source)
        #expect(measurement.block != projection.firstBlock)
        #expect(LayoutDocumentExtentIndex(
            projection: projection,
            request: request,
            capacity: capacity,
            measurements: [measurement]
        ) == nil)
    }
}
