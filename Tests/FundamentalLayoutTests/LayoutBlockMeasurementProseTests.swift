import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    @MainActor
    @Test("body measurement has narrow and wide eager parity")
    func bodyWidths() throws
    {
        let text = String(
            repeating: "Finite native measurement remains exact. ",
            count: 12
        )
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct(text)
        ]))
        let narrow = try product(block, width: 120)
        let wide = try product(block, width: 900)
        let narrowParameters = try LayoutFixture.request(width: 120)
            .parameters
        let wideParameters = try LayoutFixture.request(width: 900)
            .parameters
        #expect(narrow.measurement.kind == .prose(.body))
        #expect(wide.measurement.kind == .prose(.body))
        #expect(narrow.measurement.parameters == narrowParameters)
        #expect(wide.measurement.parameters == wideParameters)
        #expect(narrow.measurement.extents.count
            > wide.measurement.extents.count)
        expectParity(narrow.measurement, narrow.snapshot)
        expectParity(wide.measurement, wide.snapshot)
    }

    @MainActor
    @Test("title and every section level retain their exact roles")
    func headingRoles() throws
    {
        let blocks = [
            SemanticBlock.heading(.title(TitleSemanticHeading(runs: [
                LayoutFixture.direct("Title")
            ])))
        ] + SemanticHeadingLevel.allCases.map
        {
            .heading(.section(SectionSemanticHeading(
                runs: [LayoutFixture.direct("Section")],
                level: $0
            )))
        }
        let results = try blocks.map
        {
            try product($0, width: 400)
        }
        #expect(results.map(\.measurement.kind) == [
            .prose(.title),
            .prose(.section(.one)),
            .prose(.section(.two)),
            .prose(.section(.three)),
            .prose(.section(.four)),
            .prose(.section(.five)),
            .prose(.section(.six))
        ])
        for result in results
        {
            expectParity(result.measurement, result.snapshot)
        }
    }

    @MainActor
    @Test("empty prose still has one exact extent and a content font")
    func emptyProse() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: []))
        let result = try product(block, width: 320)
        #expect(result.measurement.extents.count == 1)
        #expect(!result.measurement.contentFonts.isEmpty)
        #expect(result.measurement.extents[0].frame.minY == 0)
        #expect(result.measurement.extents[0].content
            == .line(.prose(.body)))
        expectParity(result.measurement, result.snapshot)
    }
}
