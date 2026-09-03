import Testing

@testable import FundamentalMacOracle

extension MacReaderWindowTests
{
    @Test("an unmatched native appearance is refused")
    func unmatchedAppearanceIsRefused() throws
    {
        let display = try #require(MacDisplayIdentity(
            try MacOracleTestSurface.screen()
        ))
        #expect(MacAppearancePalette(
            native: MacUnmatchedAppearance(),
            display: display,
            increasedContrast: false
        ) == nil)
    }
}
