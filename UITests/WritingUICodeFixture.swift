import Foundation
import XCTest

struct WritingUICodeFixture
{
    let tagged: Bool
    let documentID = UUID()
    let blockIDs = (0 ..< 3).map { _ in UUID() }
    let language = " SwIfT "
    let source: String
    let prefix = "\tlet edited = \"e\u{301} 😀\"\r\n"

    init(
        tagged: Bool,
        source: String = "let letter = \"e\u{301} 😀\"\r\n\treturn letter\n\n"
    )
    {
        self.tagged = tagged
        self.source = source
    }

    func write(to location: URL) throws
    {
        var code = content(source, kind: tagged ? "languageCode" : "code")
        if tagged
        {
            code["language"] = language
        }
        let contents = [content("Before"), code, content("After")]
        let record: [String: Any] = [
            "format": "fundamental-document", "version": 1,
            "documentID": documentID.uuidString, "revision": 8,
            "blocks": zip(blockIDs, contents).map
            {
                ["blockID": $0.uuidString, "content": $1] as [String: Any]
            }
        ]
        let data = try JSONSerialization.data(withJSONObject: record,
                                               options: [.sortedKeys])
        try data.write(to: location, options: .withoutOverwriting)
    }

    func matches(_ record: WritingUIRecord, code: String, after: String)
        -> Bool
    {
        record.blocks.map { $0.content.runs.flatMap { Array($0.text.utf16) } }
            == ["Before", code, after].map { Array($0.utf16) }
    }

    func expect(_ record: WritingUIRecord, code: String, after: String)
    {
        XCTAssertEqual(record.format, "fundamental-document")
        XCTAssertEqual(record.version, 1)
        XCTAssertEqual(record.documentID, documentID)
        XCTAssertEqual(record.blocks.map(\.blockID), blockIDs)
        XCTAssertEqual(record.blocks.map(\.content.kind),
                       ["paragraph", tagged ? "languageCode" : "code",
                        "paragraph"])
        XCTAssertEqual(record.blocks.map(\.content.language),
                       [nil, tagged ? language : nil, nil])
        XCTAssertTrue(matches(record, code: code, after: after))
        XCTAssertTrue(record.blocks.flatMap(\.content.runs).allSatisfy
        {
            $0.traits.isEmpty && $0.link == nil && $0.language == nil
        })
    }

    private func content(_ text: String, kind: String = "paragraph")
        -> [String: Any]
    {
        ["kind": kind, "runs": [["text": text, "traits": []]]]
    }
}
