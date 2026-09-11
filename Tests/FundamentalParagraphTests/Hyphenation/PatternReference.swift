import Foundation
import Testing

@testable import FundamentalParagraph

enum PatternReference
{
    static let hashes: [String: String] = [
        "hyph-en-gb.hyp.txt":
            "232d121074ef259d6952113ba37555461f7a78dc7dc667ad3b06f9f67ad96483",
        "hyph-en-gb.pat.txt":
            "8f8d20097ae12d71bccd96eb4b299e78341d770d05576247729a54123c4ae388",
        "hyph-en-us.hyp.txt":
            "1f53d3dab995382524c7ba42ae667db6bc0cabaa6ccf74c3e3b90de12cc322b2",
        "hyph-en-us.pat.txt":
            "665b20f63ea96e0768baebd3ad7940a4069a763d7abd4efbb6647dfba77a79a8",
        "hyph-ru.hyp.txt":
            "ba34902a04f6d39d1549c1bee7ea72739eeb5e9859ff3098cb18db3c71eec3dd",
        "hyph-ru.pat.txt":
            "f424c5ddb04d4f1669b8bcba717e15ca233a018baea4fa23238350f88bc65d48"
    ]

    static func verify(
        _ tokens: [String], resource: PatternResource, suffix: String
    ) throws
    {
        let tag = resource.sourceFilename.replacingOccurrences(
            of: ".tex", with: ""
        )
        let expected = try #require(hashes[tag + "." + suffix + ".txt"])
        let ordered = tokens.map { Array($0.utf8) }.sorted
        {
            $0.lexicographicallyPrecedes($1)
        }
        let bytes = Data(ordered.flatMap { $0 + [10] })
        #expect(PatternResource.digest(bytes) == expected)
    }
}
