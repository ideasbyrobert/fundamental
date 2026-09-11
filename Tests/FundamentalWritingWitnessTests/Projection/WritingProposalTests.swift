import Foundation
import Testing

@Suite("Canonical native writing proposals")
struct WritingProposalTests
{
    func sent<Value: Sendable>(_ value: Value) -> Value
    {
        value
    }
}
