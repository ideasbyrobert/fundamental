import Testing

@testable import FundamentalDocument

@Suite("A document UTF-16 offset")
struct DocumentUTF16OffsetTests
{
    @Test("the complete nonnegative integer domain is admitted")
    func nonnegativeValuesAreAdmitted() throws
    {
        let zero = try #require(DocumentUTF16Offset(0))
        let one = try #require(DocumentUTF16Offset(1))
        let maximum = try #require(DocumentUTF16Offset(Int.max))

        #expect(zero.value == 0)
        #expect(one.value == 1)
        #expect(maximum.value == Int.max)
    }

    @Test("negative values are refused")
    func negativeValuesAreRefused()
    {
        #expect(DocumentUTF16Offset(-1) == nil)
        #expect(DocumentUTF16Offset(Int.min) == nil)
    }

    @Test("ordering follows exact admitted values")
    func orderingFollowsAdmittedValues() throws
    {
        let maximum = try #require(DocumentUTF16Offset(Int.max))
        let seven = try #require(DocumentUTF16Offset(7))
        let zero = try #require(DocumentUTF16Offset(0))

        #expect([maximum, seven, zero].sorted().map(\.value) == [0, 7, Int.max])
    }

    @Test("UTF-16 measurement preserves exact source spelling")
    func utf16MeasurementPreservesSourceSpelling() throws
    {
        let ascii = try #require(DocumentUTF16Offset("A".utf16.count))
        let precomposed = try #require(DocumentUTF16Offset("é".utf16.count))
        let decomposed = try #require(
            DocumentUTF16Offset("e\u{301}".utf16.count)
        )
        let supplementary = try #require(
            DocumentUTF16Offset("😀".utf16.count)
        )

        #expect(ascii.value == 1)
        #expect(precomposed.value == 1)
        #expect(decomposed.value == 2)
        #expect(supplementary.value == 2)
    }
}
