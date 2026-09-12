import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingFindTests
{
    @Test("Replace All checks final document capacity before publication")
    func capacity() throws
    {
        let projection = try WritingTestDocument("a a").projection()
        let query = try #require(WritingFindQuery("a", caseSensitive: true))
        let results = WritingFindResults(query, in: projection)
        let replacement = String(repeating: "x", count:
            WritingSurfacePolicy.maximumUTF16Units / 2 + 1)
        #expect(WritingFindReplacement(results, ranges: results.ranges,
            text: replacement, in: projection) == nil)
        #expect(projection.text == "a a")
    }
}
