import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension WritingMixedDocumentFixture
{
    static func read(_ source: DocumentSnapshot, suffix: String) throws
    {
        let screen = try #require(NSScreen.main)
        let appearance = try #require(NSAppearance(named: .aqua))
        let controller = try #require(MacReaderWindowController(
            contentSize: NSSize(width: 820, height: 600),
            screen: screen, appearance: appearance,
            projection: MacReaderDocumentProjection(source)
        ))
        let window = try #require(controller.window)
        defer { window.close() }
        window.appearance = appearance
        controller.showWindow(nil)
        controller.synchronize()
        let model = controller.readerView.model
        let lineage = model.snapshot.lineage.raster.viewport.layout.document
        #expect(lineage.documentID == source.document.documentID.value)
        #expect(lineage.revision == source.document.revision.value)
        #expect(lineage.projectionGeneration == source.generation.value)
        let executions = model.layoutExecutionCount
        for block in source.document.content.blocks
        {
            let residents = try reveal(block, in: controller)
            try expectSource(block, residents: residents)
            try styledReader(block, residents: residents)
            try accessibleReader(controller)
            try copy(block, residents: residents, from: controller)
            let ordinal = try #require(residents.first).residentID.blockOrdinal
            if [0, 8, 10, 14].contains(ordinal)
            {
                try captureReader(
                    controller, name: "mixed-reader-\(suffix)-\(ordinal)"
                )
            }
        }
        #expect(model.layoutExecutionCount == executions)
        #expect(!controller.scrollView.hasHorizontalScroller)
    }

    static func reveal(
        _ block: IdentifiedSemanticBlock,
        in controller: MacReaderWindowController
    ) throws -> [PresentedResident]
    {
        let clip = controller.scrollView.contentView
        let model = controller.readerView.model
        for _ in 0 ..< 30
        {
            let residents = model.snapshot.presentedDocument.residents.all
                .filter { $0.residentID.blockID == block.blockID.value }
            if let first = residents.first
            {
                clip.scroll(to: NSPoint(x: 0, y: max(0, first.frame.minY - 20)))
                controller.synchronize()
                return model.snapshot.presentedDocument.residents.all
                    .filter { $0.residentID.blockID == block.blockID.value }
            }
            clip.scroll(to: NSPoint(
                x: 0, y: clip.bounds.minY + clip.bounds.height / 2
            ))
            controller.synchronize()
        }
        Issue.record("Mixed-document block never became resident")
        return []
    }
}
