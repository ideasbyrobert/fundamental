import Testing

@testable import FundamentalDocument

extension DocumentSessionTransitionTests
{
    @Test("refusal reasons exhaustively distinguish the admitted boundary")
    func refusalVocabulary()
    {
        let reasons: [DocumentSessionRefusal] = [
            .staleObservation, .readOnly, .invalidCommand, .generationExhausted,
            .historyUnavailable, .historyCapacity
        ]
        let names = reasons.map
        {
            reason in
            switch reason
            {
            case .staleObservation:
                "stale"
            case .readOnly:
                "readable"
            case .invalidCommand:
                "invalid"
            case .generationExhausted:
                "exhausted"
            case .historyUnavailable:
                "no transaction"
            case .historyCapacity:
                "capacity"
            }
        }
        #expect(names == [
            "stale", "readable", "invalid", "exhausted", "no transaction",
            "capacity"
        ])
        for left in reasons.indices
        {
            for right in reasons.indices
            {
                #expect((reasons[left] == reasons[right]) == (left == right))
            }
        }
    }
}
