import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectLineage(
        _ source: RasterLineage,
        equals result: PresentationRasterLineage
    )
    {
        let sourceLayout = source.viewport.layout
        let resultLayout = result.viewport.layout
        #expect(sourceLayout.projection.documentID
            == resultLayout.document.documentID)
        #expect(sourceLayout.projection.revision
            == resultLayout.document.revision)
        #expect(sourceLayout.projection.generation
            == resultLayout.document.projectionGeneration)
        #expect(sourceLayout.generation == resultLayout.generation)
        #expect(sourceLayout.specification.version
            == resultLayout.specification.version)
        expectLayoutParameters(
            sourceLayout.specification.parameters,
            equals: resultLayout.specification.parameters
        )
        expectLayoutFonts(
            sourceLayout.specification.resolvedFonts,
            equals: resultLayout.specification.resolvedFonts
        )
        #expect(source.viewport.generation == result.viewport.generation)
        #expect(rectangleSignature(
            source.viewport.specification.visibleBounds
        ) == rectangleSignature(
            result.viewport.specification.visibleBounds
        ))
        #expect(source.viewport.specification.precedingOverscanExtent
            == result.viewport.specification.precedingOverscanExtent)
        #expect(source.viewport.specification.followingOverscanExtent
            == result.viewport.specification.followingOverscanExtent)
        #expect(source.viewport.specification.maximumResidentCount
            == result.viewport.specification.maximumResidentCount)
        #expect(source.generation == result.generation)
        expectRasterSpecification(
            source.specification,
            equals: result.specification
        )
    }
}
