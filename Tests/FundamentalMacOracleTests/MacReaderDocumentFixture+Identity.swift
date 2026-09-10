import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderDocumentFixture
{
    static func expectSource(
        _ source: DocumentSnapshot, in model: MacReaderModel
    ) throws
    {
        let lineage = model.snapshot.lineage.raster.viewport.layout.document
        #expect(lineage.documentID == source.document.documentID.value)
        #expect(lineage.revision == source.document.revision.value)
        #expect(lineage.projectionGeneration == source.generation.value)
        let blocks = source.document.content.blocks
        let residents = model.snapshot.presentedDocument.residents.all
        #expect(!residents.isEmpty)
        for resident in residents
        {
            let ordinal = resident.residentID.blockOrdinal
            try #require(blocks.indices.contains(ordinal))
            let block = blocks[ordinal]
            let blockID = block.blockID.value
            #expect(resident.residentID.blockID == blockID)
            let line = try #require(line(resident.content))
            let text = try runs(block.block).map(\.text).joined()
            #expect(line.sourceSlices.map(\.text).joined().utf16
                .elementsEqual(line.text.utf16))
            for slice in line.sourceSlices
            {
                #expect(slice.source.domain == .block(blockID))
                try #require(slice.range.lowerBound >= 0)
                try #require(slice.range.upperBound <= text.utf16.count)
                let units = Array(text.utf16)[slice.range]
                #expect(slice.text.utf16.elementsEqual(units))
            }
            for site in line.caretSites
            {
                #expect(site.sourcePoint.domain == .block(blockID))
                #expect((0 ... text.utf16.count).contains(
                    site.sourcePoint.utf16Offset
                ))
            }
        }
    }
}
