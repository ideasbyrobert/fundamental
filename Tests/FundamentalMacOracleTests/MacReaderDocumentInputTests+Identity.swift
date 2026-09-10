import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderDocumentInputTests
{
    @Test("explicit input begins at its admitted measure",
          arguments: [480.0, 600.0, 820.0])
    func initialMeasure(width: Double) throws
    {
        let source = try MacReaderDocumentFixture.source([
            MacReaderDocumentFixture.paragraph("An independent Reader.")
        ])
        let model = try MacReaderDocumentFixture.model(source, width: width)
        #expect(model.readableMeasure == min(720, width - 64))
        #expect(model.documentWidth == model.readableMeasure)
        #expect(model.layoutExecutionCount == 1)
        try MacReaderDocumentFixture.expectSource(source, in: model)
    }

    @Test("distinct revisions and documents have independent preparations")
    func independentReaders() throws
    {
        let original = try MacReaderDocumentFixture.source([
            MacReaderDocumentFixture.paragraph("Original source.")
        ])
        let revised = try MacReaderDocumentFixture.source([
            MacReaderDocumentFixture.paragraph("A later revision.")
        ], revision: .max, generation: .max)
        let other = try MacReaderDocumentFixture.source([
            MacReaderDocumentFixture.paragraph("Another document.")
        ], seed: 0x89)
        let first = try MacReaderDocumentFixture.model(original)
        let retained = first.snapshot
        let second = try MacReaderDocumentFixture.model(revised, width: 480)
        let third = try MacReaderDocumentFixture.model(other)
        let retainedThird = third.snapshot
        #expect(second.update(
            viewportWidth: 600, viewportHeight: 500, visibleOriginY: 0,
            screen: try MacOracleTestSurface.screen(),
            appearance: try MacOracleTestSurface.appearance(.darkAqua)
        ))
        #expect(second.layoutExecutionCount == 2)
        #expect(first.layoutExecutionCount == 1)
        #expect(third.layoutExecutionCount == 1)
        #expect(first.snapshot == retained)
        #expect(third.snapshot == retainedThird)
        try MacReaderDocumentFixture.expectSource(original, in: first)
        try MacReaderDocumentFixture.expectSource(revised, in: second)
        try MacReaderDocumentFixture.expectSource(other, in: third)
        #expect(MacReaderDocumentFixture.texts(first) == ["Original source."])
        #expect(MacReaderDocumentFixture.texts(second) == ["A later revision."])
        #expect(MacReaderDocumentFixture.texts(third) == ["Another document."])
    }
}
