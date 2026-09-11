import Foundation

enum BundledParagraphPatterns
{
    private static let cached = Result
    {
        try load(from: directory)
    }

    static var directory: URL
    {
        get throws
        {
            guard let url = Bundle.module.url(
                forResource: "Hyphenation", withExtension: nil
            )
            else
            {
                throw PatternFailure.invalidResource
            }
            return url
        }
    }

    static func catalog() throws -> OwnedPatternCatalog
    {
        try cached.get()
    }

    static func load(from directory: URL) throws -> OwnedPatternCatalog
    {
        try OwnedPatternCatalog(
            resources: resources(in: directory), directory: directory
        )
    }

    static func resources(in directory: URL) throws -> [PatternResource]
    {
        let path = directory.appending(path: "manifest.json")
        let data = try Data(contentsOf: path)
        let expected =
            "ae944f3a8df2b4dc7bccfc71b2574f377435e295fa744b97533b773f102fd7f6"
        guard PatternResource.digest(data) == expected
        else
        {
            throw PatternFailure.checksumMismatch
        }
        return try JSONDecoder().decode([PatternResource].self, from: data)
    }
}
