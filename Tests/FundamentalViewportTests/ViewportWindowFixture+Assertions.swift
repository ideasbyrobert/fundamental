import Testing

@testable import FundamentalViewport

extension ViewportWindowFixture
{
    static func expectExact(_ value: ViewportWindowTestProduct)
    {
        #expect(value.diagnostics.snapshot == value.expected)
        let eager = ViewportSnapshot.admissionDiagnostics(
            value.eager,
            request: value.request
        )
        #expect(value.diagnostics.query == eager?.query)
    }

    static func requireSendable<T: Sendable>(_ value: T)
    {
        _ = value
    }
}
