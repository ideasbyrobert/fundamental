import Testing

@testable import FundamentalDocument

extension DocumentHistoryTests
{
    @Test
    func limitsHaveRequiredPositiveDefaults() throws
    {
        let standard = DocumentHistoryLimits()
        #expect(standard.transactions == 64)
        #expect(standard.retainedUTF16Units == 1_048_576)
        let minimal = try #require(DocumentHistoryLimits(
            transactions: 1,
            retainedUTF16Units: 1
        ))
        #expect(minimal.transactions == 1)
        #expect(minimal.retainedUTF16Units == 1)
    }

    @Test(arguments: [0, -1, Int.min])
    func nonpositiveLimitsRefuse(_ invalid: Int)
    {
        #expect(DocumentHistoryLimits(
            transactions: invalid,
            retainedUTF16Units: 1
        ) == nil)
        #expect(DocumentHistoryLimits(
            transactions: 1,
            retainedUTF16Units: invalid
        ) == nil)
    }
}
