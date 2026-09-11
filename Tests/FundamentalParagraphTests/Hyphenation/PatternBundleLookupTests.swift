import Foundation
import Testing

@testable import FundamentalParagraph

@Suite("Missing pattern bundle is an explicit refusal")
struct PatternBundleLookupTests
{
    @Test
    func absentCandidatesDoNotTerminateTheProcess()
    {
        #expect(throws: PatternFailure.invalidResource)
        {
            try ParagraphPatternBundle.directory(in: [])
        }
    }

    @Test
    func aMissingBundleDoesNotUseUndeclaredFallbacks() throws
    {
        let root = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(
            at: root, withIntermediateDirectories: false
        )
        defer
        {
            try? FileManager.default.removeItem(at: root)
        }
        #expect(throws: PatternFailure.invalidResource)
        {
            try ParagraphPatternBundle.directory(in: [root])
        }
    }
}
