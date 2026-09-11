import Foundation

private final class ParagraphPatternBundleAnchor
{
}

enum ParagraphPatternBundle
{
    static func directory() throws -> URL
    {
        let containing = Bundle(for: ParagraphPatternBundleAnchor.self)
        let candidates = [
            Bundle.main.resourceURL, containing.resourceURL,
            Bundle.main.bundleURL
        ].compactMap { $0 }
        return try directory(in: candidates)
    }

    static func directory(in candidates: [URL]) throws -> URL
    {
        for candidate in candidates
        {
            let path = candidate.appending(
                path: "Fundamental_FundamentalParagraph.bundle"
            )
            if let bundle = Bundle(url: path),
               let directory = bundle.url(
                   forResource: "Hyphenation", withExtension: nil
               )
            {
                return directory
            }
        }
        throw PatternFailure.invalidResource
    }
}
