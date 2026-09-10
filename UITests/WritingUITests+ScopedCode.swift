import XCTest

extension WritingUITests
{
    func testScopedPlainCodePreservesSourceThroughDailyEditing() throws
    {
        try exerciseCode(tagged: false, scoped: true)
    }

    func testScopedTaggedCodePreservesSourceThroughDailyEditing() throws
    {
        try exerciseCode(tagged: true, scoped: true)
    }
}
