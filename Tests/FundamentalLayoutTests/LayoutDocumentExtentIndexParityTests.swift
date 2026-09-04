import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    @Test("mixed document facts equal eager layout exactly")
    func mixedParity() throws
    {
        let result = try product(try mixedBlocks(), width: 360)
        expectParity(result.index, result.snapshot)
        #expect(result.index.extents.map(\.anchor)
            == result.index.extents.map(\.localExtent.anchor))
        #expect(Set(result.index.extents.map(\.anchor)).count
            == result.index.extents.count)
    }

    @MainActor
    @Test("block spacing occurs only between exact block extents")
    func spacing() throws
    {
        let blocks: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: [])),
            .code(.plain(PlainSemanticCodeBlock(runs: []))),
            try emptyTable()
        ]
        let result = try product(blocks, width: 320)
        let frames = result.projection.blocks.indices.map
        {
            ordinal in
            result.index.extents.filter
            {
                $0.source.ordinal == ordinal
            }.map(\.frame)
        }
        #expect(frames[0].map(\.minY).min() == 0)
        for index in frames.indices.dropFirst()
        {
            let preceding = try #require(frames[index - 1]
                .map(\.maxY).max())
            let following = try #require(frames[index]
                .map(\.minY).min())
            #expect(following - preceding
                == result.request.parameters.blockSpacing)
        }
        #expect(result.index.size.height
            == frames.last?.map(\.maxY).max())
        expectParity(result.index, result.snapshot)
    }

    @MainActor
    @Test("narrow wide Unicode and oversized tables preserve parity")
    func widthAndUnicode() throws
    {
        let text = "cafe\u{301} مرحبا שלום कि "
            + "✈️ 👩🏽‍💻 🇦🇲"
        let blocks: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct(text)
            ])),
            .table(try LayoutFixture.table(captioned: true))
        ]
        for width in [40.0, 720]
        {
            let result = try product(blocks, width: width)
            expectParity(result.index, result.snapshot)
            #expect(result.index.extents.contains
            {
                $0.source.ordinal == 1
            })
            if width == 40
            {
                #expect(result.index.size.width > width)
            }
        }
    }
}
