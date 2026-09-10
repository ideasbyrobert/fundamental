import XCTest

extension WritingUIScopeFixture
{
    func matches(
        _ record: WritingUIRecord, texts: [String], forms: [Int],
        traits: [String] = []
    ) -> Bool
    {
        guard record.format == "fundamental-document", record.version == 1,
              record.documentID == documentID, texts.count == forms.count,
              record.blocks.count == texts.count
        else
        {
            return false
        }
        return record.blocks.enumerated().allSatisfy
        {
            index, block in
            let runs = block.content.runs
            guard block.content.kind == "paragraph",
                  runs.flatMap({ Array($0.text.utf16) }) ==
                    Array(texts[index].utf16)
            else
            {
                return false
            }
            return runs.filter { !$0.text.isEmpty }.allSatisfy
            {
                run in
                let linkMatches = forms[index] == 1 ? run.link == nil :
                    run.link?.utf16.elementsEqual(Self.link.utf16) == true
                let languageMatches = forms[index] == 0 ? run.language == nil :
                    run.language?.utf16.elementsEqual(
                        Self.language.utf16
                    ) == true
                return linkMatches && languageMatches &&
                    run.traits.sorted() == traits.sorted()
            }
        }
    }

    func expectIdentity(_ record: WritingUIRecord, inserted: Bool = false)
    {
        let positions = inserted ? [0, 2, 3] : [0, 1, 2]
        guard record.blocks.count == (inserted ? 4 : 3)
        else
        {
            XCTFail("Expected every original scoped paragraph")
            return
        }
        XCTAssertEqual(positions.map { record.blocks[$0].blockID }, blockIDs)
        XCTAssertEqual(Set(record.blocks.map(\.blockID)).count,
                       record.blocks.count)
    }
}
