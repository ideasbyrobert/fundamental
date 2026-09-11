import XCTest

extension WritingUICodeFixture
{
    func expectScopes(_ record: WritingUIRecord)
    {
        for (index, block) in record.blocks.enumerated()
        {
            for run in block.content.runs
            {
                XCTAssertTrue(run.traits.isEmpty)
                if scoped && index == 1 && !run.text.isEmpty
                {
                    XCTAssertTrue(run.link?.utf16.elementsEqual(
                        WritingUIScopeFixture.link.utf16
                    ) == true)
                    XCTAssertTrue(run.language?.utf16.elementsEqual(
                        WritingUIScopeFixture.language.utf16
                    ) == true)
                }
                else if !scoped || index != 1
                {
                    XCTAssertNil(run.link)
                    XCTAssertNil(run.language)
                }
            }
        }
    }
}
