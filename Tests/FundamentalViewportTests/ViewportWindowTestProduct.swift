@testable import FundamentalLayout
@testable import FundamentalProjection
@testable import FundamentalViewport

struct ViewportWindowTestProduct
{
    let projection: ProjectionSnapshot
    let eager: LayoutSnapshot
    let indexed: LayoutIndexedProjection
    let request: ViewportRequest
    let expected: ViewportSnapshot
    let diagnostics: ViewportWindowAdmissionDiagnostics
}
