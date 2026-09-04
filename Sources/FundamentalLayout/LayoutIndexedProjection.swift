import FundamentalProjection

package struct LayoutIndexedProjection: Equatable, Sendable
{
    let projection: ProjectionSnapshot
    let index: LayoutDocumentExtentIndex
    private let blockResolvedFonts: [[LayoutFontIdentity]]

    fileprivate init?(
        projection: ProjectionSnapshot,
        index: LayoutDocumentExtentIndex,
        measurements: [LayoutBlockMeasurement]
    )
    {
        let fonts = measurements.map(\.resolvedFonts)
        guard !fonts.contains(where: \.isEmpty)
        else
        {
            return nil
        }
        self.projection = projection
        self.index = index
        blockResolvedFonts = fonts
    }

    func resolvedFonts(
        atBlockOrdinal ordinal: Int
    ) -> [LayoutFontIdentity]?
    {
        guard blockResolvedFonts.indices.contains(ordinal)
        else
        {
            return nil
        }
        return blockResolvedFonts[ordinal]
    }
}

extension NativeTextKit2Layout
{
    func indexedProjection(
        _ projection: ProjectionSnapshot,
        request: LayoutRequest,
        capacity: LayoutExtentIndexCapacity
    ) throws -> LayoutIndexedProjection
    {
        let blocks = projection.blocks
        guard blocks.count <= capacity.maximumBlockCount
        else
        {
            throw LayoutFailure.unrepresentableDocumentExtentIndex
        }
        let measurements = try blocks.map
        {
            try measure($0, parameters: request.parameters)
        }
        guard let index = LayoutDocumentExtentIndex(
            projection: projection,
            request: request,
            capacity: capacity,
            measurements: measurements
        )
        else
        {
            throw LayoutFailure.unrepresentableDocumentExtentIndex
        }
        guard let result = LayoutIndexedProjection(
            projection: projection,
            index: index,
            measurements: measurements
        )
        else
        {
            throw LayoutFailure.unrepresentableDocumentExtentIndex
        }
        return result
    }
}
