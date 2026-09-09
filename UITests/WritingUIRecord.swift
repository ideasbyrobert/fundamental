import Foundation
import XCTest

struct WritingUIRecord: Decodable
{
    let documentID: UUID
    let revision: Int
    let format: String
    let version: Int
    let blocks: [Block]

    struct Block: Decodable
    {
        let blockID: UUID
        let content: Content
    }

    struct Content: Decodable
    {
        let kind: String
        let level: Int?
        let listKind: String?
        let runs: [Run]
    }

    struct Run: Decodable
    {
        let text: String
        let traits: [String]
    }

    init(at location: URL) throws
    {
        self = try JSONDecoder().decode(Self.self,
                                        from: Data(contentsOf: location))
    }

    func expect(numbered: Bool, texts: [String])
    {
        XCTAssertEqual(format, "fundamental-document")
        XCTAssertEqual(version, numbered ? 2 : 1)
        XCTAssertEqual(blocks.map(\.content.kind),
                       ["section"] + Array(repeating:
                        numbered ? "listItem" : "paragraph", count: 2))
        XCTAssertEqual(blocks.first?.content.level, 2)
        XCTAssertEqual(blocks.dropFirst().map(\.content.listKind),
                       Array(repeating: numbered ? "numbered" : nil, count: 2))
        let actual = blocks.map
        {
            $0.content.runs.flatMap { Array($0.text.utf16) }
        }
        XCTAssertEqual(actual, texts.map { Array($0.utf16) })
        XCTAssertTrue(blocks.flatMap(\.content.runs)
            .allSatisfy { $0.traits.isEmpty })
        XCTAssertEqual(Set(blocks.map(\.blockID)).count, 3)
    }
}
