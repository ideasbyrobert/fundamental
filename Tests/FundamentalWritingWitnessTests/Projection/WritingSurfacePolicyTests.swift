import Testing

@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func witnessPolicyIsExplicitAndBounded()
    {
        #expect(WritingSurfacePolicy.maximumUTF16Units == 65_536)
        #expect(WritingSurfacePolicy.readableMeasure == 720)
        #expect(WritingSurfacePolicy.admits(""))
        #expect(WritingSurfacePolicy.admits("English 123 😀 e\u{301}"))
        #expect(!WritingSurfacePolicy.admits("\r"))
        #expect(!WritingSurfacePolicy.admits("\n"))
        #expect(!WritingSurfacePolicy.admits("\r\n"))
    }
}
