import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacNativeResourceAdmissionTests
{
    @Test("poisoned caret color refuses complete execution")
    func poisonedCaretColorRefusesExecution() throws
    {
        let model = try MacOracleTestSurface.model()
        let (first, _) = try Self.positions(in: model)
        #expect(model.showCaret(at: first))
        let source = model.snapshot
        let color = try #require(
            MacRasterSnapshotFixture.mismatchedColor(in: source)
        )
        let poisoned = try #require(
            MacRasterSnapshotFixture.replacingCaretColor(
                in: source,
                with: color
            )
        )
        #expect(MacRasterExecutor().admit(poisoned) == nil)
    }

    @Test("poisoned selection color refuses complete execution")
    func poisonedSelectionColorRefusesExecution() throws
    {
        let model = try MacOracleTestSurface.model()
        let (first, last) = try Self.positions(in: model)
        #expect(model.showSelection(anchor: first, focus: last))
        let source = model.snapshot
        let color = try #require(
            MacRasterSnapshotFixture.mismatchedColor(in: source)
        )
        let poisoned = try #require(
            MacRasterSnapshotFixture.replacingSelectionColor(
                in: source,
                with: color
            )
        )
        #expect(MacRasterExecutor().admit(poisoned) == nil)
    }

    private static func positions(
        in model: MacReaderModel
    ) throws -> (PresentationTextPosition, PresentationTextPosition)
    {
        let (resident, line) = try MacReaderInteractionTests.line(
            in: model.snapshot
        )
        let first = try #require(line.caretSites.first)
        let last = try #require(line.caretSites.last)
        return (
            PresentationTextPosition(
                residentID: resident.residentID,
                sourcePoint: first.sourcePoint
            ),
            PresentationTextPosition(
                residentID: resident.residentID,
                sourcePoint: last.sourcePoint
            )
        )
    }
}
