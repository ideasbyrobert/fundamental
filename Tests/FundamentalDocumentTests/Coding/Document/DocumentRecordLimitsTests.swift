import Testing

@testable import FundamentalDocument

@Suite("Owned document resource limits")
struct DocumentRecordLimitsTests
{
    @Test("standard limits declare the complete admitted file boundary")
    func standardLimits()
    {
        let limits = DocumentRecordLimits()
        #expect(limits.maximumBytes == 67_108_864)
        #expect(limits.maximumBlocks == 100_000)
    }

    @Test("only positive explicit byte and block bounds are admitted")
    func positiveBounds()
    {
        for value in [Int.min, -1, 0]
        {
            #expect(DocumentRecordLimits(
                maximumBytes: value,
                maximumBlocks: 1
            ) == nil)
            #expect(DocumentRecordLimits(
                maximumBytes: 1,
                maximumBlocks: value
            ) == nil)
        }
        #expect(DocumentRecordLimits(maximumBytes: 1, maximumBlocks: 1) != nil)
    }
}
