import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle

extension MacReaderDocumentFixture
{
    static func window(
        _ source: DocumentSnapshot,
        width: Double = 820, height: Double = 760
    ) throws -> MacReaderWindowController
    {
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        return try #require(MacReaderWindowController(
            contentSize: NSSize(width: width, height: height),
            screen: screen, appearance: appearance,
            projection: MacReaderDocumentProjection(source)
        ))
    }
}
