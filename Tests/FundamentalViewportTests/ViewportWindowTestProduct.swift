@testable import FundamentalLayout
@testable import FundamentalViewport

struct ViewportWindowTestProduct
{
    let eager: LayoutSnapshot
    let indexed: LayoutIndexedProjection
    let request: ViewportRequest
    let expected: ViewportSnapshot
    let diagnostics: ViewportWindowAdmissionDiagnostics
}
