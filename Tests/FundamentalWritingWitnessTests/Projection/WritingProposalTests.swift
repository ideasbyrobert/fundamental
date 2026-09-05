import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@Suite("Canonical native writing proposals")
struct WritingProposalTests
{
    func sent<Value: Sendable>(_ value: Value) -> Value
    {
        value
    }
}
