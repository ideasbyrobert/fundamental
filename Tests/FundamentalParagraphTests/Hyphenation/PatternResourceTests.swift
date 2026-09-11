@testable import FundamentalParagraph
import Foundation
import Testing

@Suite
struct PatternResourceTests
{
    @Test(arguments: PatternFixture.languages)
    func importsEveryPinnedPatternAndException(_ locale: String) throws
    {
        let resource = try PatternFixture.resource(locale)
        let root = try PatternFixture.directory()
        let data = try resource.load(from: root)
        try PatternReference.verify(
            data.patterns.map(\.spelling), resource: resource, suffix: "pat"
        )
        try PatternReference.verify(
            data.exceptions.map(\.spelling), resource: resource, suffix: "hyp"
        )
        let counts = locale == "en_US" ? [4938, 14]
            : locale == "en_GB" ? [8527, 8] : [7021, 184]
        #expect(data.patterns.count == counts[0])
        #expect(data.exceptions.count == counts[1])
        #expect(resource.revision == "5684c0f51c0b81133db2efbe60a408b4155a3ff5")
        let bytes = try Data(contentsOf: root.appendingPathComponent(
            resource.filename
        ))
        let marker = try #require(bytes.range(of: Data("% title: ".utf8)))
        let original = Data(bytes[marker.lowerBound...])
        #expect(PatternResource.digest(original) == resource.sourceSHA256)
        #expect(PatternResource.digest(bytes) == resource.sha256)
        let dictionary = try resource.dictionary(from: root)
        try PatternEvidence.write(locale, group: "imports", record: [
            "locale": locale, "revision": resource.revision,
            "patterns": data.patterns.count,
            "exceptions": data.exceptions.count,
            "sourceSHA256": PatternResource.digest(original),
            "sha256": PatternResource.digest(bytes),
            "trieNodes": dictionary.trie.nodes.count,
            "maximumPatternLength": dictionary.trie.maximumLength,
            "left": resource.left, "right": resource.right
        ])
    }
}
