@testable import FundamentalParagraph
import Foundation
import Testing

@Suite
struct OwnedCatalogTests
{
    @Test
    func malformedCatalogsFailBeforeResourceIO() throws
    {
        let catalog = try OwnedPatternCatalog.bundled()
        let entries = catalog.resources
        let first = try #require(entries.first)
        let unknown = PatternResource(
            locale: "en-US", filename: first.filename,
            sourceFilename: first.sourceFilename, revision: first.revision,
            sourceSHA256: first.sourceSHA256, sha256: first.sha256,
            left: first.left, right: first.right, license: first.license
        )
        let cases = [
            Array(entries.dropLast()),
            entries + [first],
            [unknown] + Array(entries.dropFirst())
        ]
        let missing = URL(fileURLWithPath: "/nonexistent-owned-patterns")
        for resources in cases
        {
            #expect(throws: OwnedCandidateFailure.invalidCatalog)
            {
                try OwnedPatternCatalog(
                    resources: resources, directory: missing
                )
            }
        }
        try PatternEvidence.write(
            "catalog", group: "owned-corruption", record: [
                "rejectedLocales": cases.map { $0.map(\.locale) },
                "beforeResourceIO": true
            ]
        )
    }
}
