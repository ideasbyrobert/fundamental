import CryptoKit
import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticTableRecordEncodingTests
{
    static func fullGoldenData() -> Data
    {
        let text =
            #"{"evidence":[{"kind":"sourceLocation","location":"table:1","ta"# +
            #"rget":{"kind":"table"}},{"confidence":0.75,"kind":"confidence""# +
            #","target":{"kind":"table"}},{"kind":"repair","repair":"headerR"# +
            #"owCountClamped","target":{"kind":"table"}},{"kind":"sourceLoca"# +
            #"tion","location":"row:0","target":{"kind":"row","row":0}},{"co"# +
            #"nfidence":1,"kind":"confidence","target":{"cell":0,"kind":"cel"# +
            #"l","row":0}},{"kind":"repair","repair":"contradictoryCellHeade"# +
            #"rFlagDiscarded","target":{"cell":0,"kind":"cell","row":0}},{"k"# +
            #"ind":"repair","repair":"blankSourceLocationDiscarded","target""# +
            #":{"kind":"row","row":1}},{"confidence":0.5,"kind":"confidence""# +
            #","target":{"cell":0,"kind":"cell","row":1}},{"kind":"repair",""# +
            #"repair":"nonpositiveRowSpanNormalizedToOne","target":{"cell":0"# +
            #","kind":"cell","row":1}}],"record":"sourced","table":{"caption"# +
            #"":[{"text":"Caption","traits":["emphasis"]},{"language":"hy",""# +
            #"link":"chapter/one","text":"Scope","traits":["strong"]}],"cont"# +
            #"ent":{"bodyRows":[{"cells":[{"alignment":"center","extent":{"c"# +
            #"olumns":2,"rows":1},"kind":"spanning","runs":[{"language":"hy""# +
            #","link":"chapter/one","text":"Body","traits":["emphasis","stro"# +
            #"ng"]}]}]}],"columnAlignments":["leading","center"],"headerRows"# +
            #"":[{"cells":[{"alignment":"leading","kind":"regular","runs":[{"# +
            #""text":"Head","traits":[]}]}]}]},"kind":"captioned"}}"#
        return Data((text + "\n").utf8)
    }

    @Test("encoding canonicalizes traits and evidence order")
    func encodingCanonicalizesTraitsAndEvidenceOrder() throws
    {
        let text = try Self.text(SemanticTableRecordCodec.encode(
            SemanticTableRecordRoundTripTests.fullRecord()
        ))
        let location = try #require(text.range(
            of: #""kind":"sourceLocation""#
        ))
        let confidence = try #require(text.range(
            of: #""kind":"confidence""#
        ))
        let repair = try #require(text.range(
            of: #""kind":"repair""#
        ))
        #expect(location.lowerBound < confidence.lowerBound)
        #expect(confidence.lowerBound < repair.lowerBound)
        #expect(text.contains(#""traits":["emphasis","strong"]"#))
    }

    @Test("minimal semantic regular golden bytes remain exact")
    func minimalSemanticRegularGoldenBytesRemainExact() throws
    {
        let root =
            #"{"record":"semantic","table":{"content":{"bodyRows":[],"# +
            #""columnAlignments":[],"headerRows":[]},"kind":"regular"}}"#
        let expected = Data(
            (root + "\n").utf8
        )
        let actual = try SemanticTableRecordCodec.encode(
            try Self.minimalRecord()
        )

        #expect(actual == expected)
        #expect(actual.count == 113)
        #expect(Self.digest(actual) ==
            "44d88925b7d484d6758903f086a774c82a15b134556343f250c1a903f31b341f")
    }

    @Test("full sourced captioned golden bytes remain exact")
    func fullSourcedCaptionedGoldenBytesRemainExact() throws
    {
        let expected = Self.fullGoldenData()
        let actual = try SemanticTableRecordCodec.encode(
            try SemanticTableRecordRoundTripTests.fullRecord()
        )

        #expect(actual == expected)
        #expect(actual.count == 1_294)
        #expect(Self.digest(actual) ==
            "1e8c502b44736d3d9bde18d432f59ff782571139de51c6d5cd606535665885da")
        #expect(actual.last == 0x0A)
        #expect(try Self.text(actual).contains("chapter/one"))
    }

    static func digest(_ data: Data) -> String
    {
        SHA256.hash(data: data).map
        {
            String(format: "%02x", $0)
        }.joined()
    }
}
