import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    func expectPoisonedFontRefusal() throws
    {
        let blocks: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("Font lineage")
            ])),
            try emptyTable()
        ]
        for block in blocks
        {
            let value = try product([block])
            let layout = NativeTextKit2Layout()
            let measurement = try layout.measure(
                value.projection.firstBlock,
                parameters: value.request.parameters
            )
            let poisoned = try poison(measurement)
            let index = try #require(LayoutDocumentExtentIndex(
                projection: value.projection,
                request: value.request,
                capacity: try indexCapacity(),
                measurements: [poisoned]
            ))
            let selection = try #require(index.selection(
                expectedLineage: index.lineage,
                extents: index.extents
            ))
            let laid = try layout.blockLayout(
                value.projection.firstBlock,
                originY: 0,
                parameters: value.request.parameters
            )
            #expect(layout.reconstructedFontsAreAdmitted(
                laid,
                as: measurement.resolvedFonts
            ))
            #expect(!layout.reconstructedFontsAreAdmitted(
                laid,
                as: poisoned.resolvedFonts
            ))
            #expect(try layout.materialize(
                indexed: value.indexed,
                selection: selection,
                capacity: try generousCapacity()
            ) == nil)
        }
        try expectBlockLocalFontAssociation()
    }

    func poison(
        _ measurement: LayoutBlockMeasurement
    ) throws -> LayoutBlockMeasurement
    {
        let kind: LayoutBlockMeasurementKind
        switch measurement.kind
        {
        case .prose, .code:
            kind = measurement.kind
        case let .table(table):
            kind = .table(try #require(LayoutTableMeasurement(
                rowCount: table.rowCount,
                cellCount: table.cellCount,
                structuralFont: poison(table.structuralFont)
            )))
        }
        let content = measurement.contentFonts.isEmpty
            ? []
            : [poison(measurement.contentFonts[0])]
        return try #require(LayoutBlockMeasurement(
            block: measurement.block,
            parameters: measurement.parameters,
            kind: kind,
            firstExtent: measurement.firstExtent,
            remainingExtents: measurement.remainingExtents,
            contentFonts: content
        ))
    }
}
