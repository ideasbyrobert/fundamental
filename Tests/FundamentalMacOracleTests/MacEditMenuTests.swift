import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderInteractionTests
{
    @Test("the native Edit copy command has no fixed target")
    func editCopyUsesResponderTargeting() throws
    {
        let application = NSApplication.shared
        let previous = application.mainMenu
        defer
        {
            application.mainMenu = previous
        }
        MacApplicationMenu.install(in: application)
        let main = try #require(application.mainMenu)
        let edit = try #require(main.item(at: 1)?.submenu)
        let copy = try #require(edit.item(at: 0))
        #expect(copy.action == #selector(NSText.copy(_:)))
        #expect(copy.target == nil)
    }
}
