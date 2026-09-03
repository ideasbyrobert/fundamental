import Testing

@testable import FundamentalViewport

@Suite("The viewport vocabulary")
struct ViewportVocabularyTests
{
    @Test("residence admits visible and both overscan positions")
    func exactCases()
    {
        let values: [ViewportResidence] = [
            .visible,
            .overscan(.preceding),
            .overscan(.following)
        ]
        #expect(values.count == 3)
        #expect(values[0] == .visible)
        #expect(values[1] == .overscan(.preceding))
        #expect(values[2] == .overscan(.following))
    }

    @Test("viewport values are equatable and sendable")
    func valueSemantics()
    {
        #expect(ViewportResidence.visible == .visible)
        requireSendable(ViewportResidence.self)
        requireSendable(ViewportOverscanPosition.self)
        requireSendable(ResidentLayoutFragment.self)
        requireSendable(ViewportResidents.self)
        requireSendable(ViewportSourceAnchor.self)
        requireSendable(ViewportSpecificationIdentity.self)
        requireSendable(ViewportLineage.self)
        requireSendable(ViewportRequest.self)
        requireSendable(ViewportSnapshot.self)
    }

    func requireSendable<T: Sendable>(_ type: T.Type)
    {
    }
}
