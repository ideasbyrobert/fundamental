import XCTest

extension WritingUIJourney
{
    func saveComposition(_ text: String, numbered: Bool) throws
        -> WritingUIRecord
    {
        let kind = numbered ? "listItem" : "paragraph"
        let list: String? = numbered ? "numbered" : nil
        let record = try save
        {
            record in
            let actual = record.blocks.flatMap(\.content.runs)
                .flatMap { Array($0.text.utf16) }
            return actual == Array(text.utf16) &&
                record.blocks.map(\.content.kind) == [kind] &&
                record.blocks.map(\.content.listKind) == [list]
        }
        XCTAssertEqual(record.format, "fundamental-document")
        XCTAssertEqual(record.version, numbered ? 2 : 1)
        XCTAssertEqual(record.blocks.map(\.content.level), [nil])
        XCTAssertTrue(record.blocks.flatMap(\.content.runs)
            .allSatisfy { $0.traits.isEmpty })
        return record
    }
}
