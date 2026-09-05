import Testing

@testable import FundamentalMacOracle

@Suite("Native admission workloads retain actual resources")
@MainActor
struct MacAdmissionWorkloadTests
{
    @Test("document workloads preserve repeated colors and ordered fonts")
    func exactDocumentWorkload() throws
    {
        let snapshot = try MacOracleTestSurface.snapshot()
        let workload = MacAdmissionWorkload(snapshot)
        let document = snapshot.presentedDocument
        #expect(workload.snapshot == snapshot)
        #expect(workload.colors.count == document.marks.count + 1)
        #expect(workload.colors.first == document.plane.palette
            .documentBackground)
        var fontIndex = 0
        for (index, mark) in document.marks.enumerated()
        {
            switch mark
            {
            case let .fill(fill):
                #expect(workload.colors[index + 1] == fill.color)
            case let .glyphs(batch):
                #expect(workload.colors[index + 1] == batch.color)
                #expect(workload.fonts[fontIndex].identity == batch.font)
                #expect(workload.fonts[fontIndex].text.utf16.elementsEqual(
                    batch.sourceSlices.map(\.text).joined().utf16
                ))
                fontIndex += 1
            }
        }
        #expect(workload.fonts.count == fontIndex)
        #expect(workload.fonts.contains
        {
            $0.text.unicodeScalars.contains("\u{301}")
        })
        #expect(workload.colors.filter
        {
            $0 == document.plane.palette.text
        }.count > 1)
    }

    @Test(
        "adornments add exactly their existing color",
        arguments: [false, true]
    )
    func adornmentWorkload(selection: Bool) throws
    {
        let model = try MacOracleTestSurface.model()
        let before = MacAdmissionWorkload(model.snapshot)
        let (first, last) = try MacReaderRasterPublicationTests.positions(
            in: model
        )
        #expect(selection
            ? model.showSelection(anchor: first, focus: last)
            : model.showCaret(at: first))
        let after = MacAdmissionWorkload(model.snapshot)
        #expect(Array(after.colors.dropLast()) == before.colors)
        #expect(after.fonts.count == before.fonts.count)
        switch model.snapshot
        {
        case let .caret(_, caret):
            #expect(after.colors.last == caret.color)
        case let .selection(_, selection):
            #expect(after.colors.last == selection.color)
        case .document:
            Issue.record("The interaction did not publish")
        }
    }
}
