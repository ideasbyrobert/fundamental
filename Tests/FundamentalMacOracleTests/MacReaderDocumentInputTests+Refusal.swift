import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle

extension MacReaderDocumentInputTests
{
    @Test("invalid input geometry is refused without publishing",
          arguments: [
            (0.0, 680.0), (64.0, 680.0), (-1.0, 680.0),
            (Double.nan, 680.0), (Double.infinity, 680.0),
            (820.0, 0.0), (820.0, -1.0),
            (820.0, Double.nan), (820.0, Double.infinity)
          ])
    func invalidGeometry(size: (Double, Double)) throws
    {
        let source = try MacReaderDocumentFixture.source([
            MacReaderDocumentFixture.paragraph("Preserve this source.")
        ])
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        let projection = MacReaderDocumentProjection(source)
        let admitted = MacReaderModel(
            viewportWidth: size.0, viewportHeight: size.1,
            screen: screen, appearance: appearance, projection: projection
        ) != nil
        #expect(!admitted)
        let opened = MacReaderWindowController(
            contentSize: NSSize(width: size.0, height: size.1),
            screen: screen, appearance: appearance, projection: projection
        ) != nil
        #expect(!opened)
        let model = try MacReaderDocumentFixture.model(source)
        let snapshot = model.snapshot
        let updated = model.update(
            viewportWidth: size.0, viewportHeight: size.1, visibleOriginY: 0,
            screen: screen, appearance: appearance
        )
        #expect(!updated)
        #expect(model.snapshot == snapshot)
        #expect(model.layoutExecutionCount == 1)
    }
}
