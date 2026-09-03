import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderWindowTests
{
    @Test("light and dark native appearances resolve distinct palettes")
    func appearancesResolveDistinctPalettes() throws
    {
        let light = try MacOracleTestSurface.model(
            appearanceName: .aqua
        ).snapshot.presentedDocument.plane.palette
        let dark = try MacOracleTestSurface.model(
            appearanceName: .darkAqua
        ).snapshot.presentedDocument.plane.palette
        #expect(light.documentBackground != dark.documentBackground)
        #expect(light.text != dark.text)
    }

}
