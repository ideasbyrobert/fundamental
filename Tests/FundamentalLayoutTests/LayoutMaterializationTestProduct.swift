@testable import FundamentalLayout
@testable import FundamentalProjection

struct LayoutMaterializationTestProduct
{
    let indexed: LayoutIndexedProjection
    let request: LayoutRequest
    let eager: LayoutSnapshot

    var projection: ProjectionSnapshot
    {
        indexed.projection
    }

    var index: LayoutDocumentExtentIndex
    {
        indexed.index
    }
}
