import Foundation
import Testing

@testable import FundamentalDocument

extension SemanticBlockRecordCodecTests
{
    @Test("owned run records refuse repair and retain precise failure paths")
    func malformedRunsRefuse()
    {
        let runs = [
            #"{"text":"x","traits":["strong","strong"]}"#,
            #"{"text":"x","traits":["future"]}"#,
            #"{"text":"x","traits":[],"link":" "}"#,
            #"{"text":"x","traits":[],"language":null}"#,
            #"{"text":"x","traits":[],"unknown":1}"#,
            #"{"text":null,"traits":[]}"#
        ]
        for run in runs
        {
            let value = #"{"kind":"paragraph","runs":[\#(run)]}"#
            #expect(throws: (any Error).self)
            {
                try SemanticBlockRecordCodec.decode(Data(value.utf8))
            }
        }
    }

    @Test("nested failures identify the original document field")
    func nestedFailurePath() throws
    {
        let value: [String: Any] = [
            "kind": "paragraph",
            "runs": [["text": "x", "traits": [], "link": " "]]
        ]
        do
        {
            _ = try SemanticBlockRecordCodec.decodeRecord(
                value,
                path: ["blocks", "2"]
            )
            Issue.record("Invalid owned scope was accepted")
        }
        catch DecodingError.dataCorrupted(let context)
        {
            #expect(context.codingPath.map(\.stringValue) == [
                "blocks", "2", "runs", "0", "link"
            ])
        }
    }
}
