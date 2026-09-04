import FundamentalProjection

extension NativeTextKit2Layout
{
    func extentIndex(
        _ projection: ProjectionSnapshot,
        request: LayoutRequest,
        capacity: LayoutExtentIndexCapacity
    ) throws -> LayoutDocumentExtentIndex
    {
        guard projection.blocks.count <= capacity.maximumBlockCount
        else
        {
            throw LayoutFailure.unrepresentableDocumentExtentIndex
        }
        let measurements = try projection.blocks.map
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
        return index
    }
}
