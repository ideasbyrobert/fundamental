import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("scope editors are available from the existing Text group")
    func scopeControlsMenuAdmission() throws
    {
        let source = try WritingTestDocument("A").state
        let window = try WritingTestWindow(session: DocumentSession(
            state: source, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let menu = try #require(window.controller.formatting.text.menu)
        for identifier in ["FundamentalLinkScope", "FundamentalLanguageScope"]
        {
            #expect(menu.items.contains
            {
                $0.identifier?.rawValue == identifier
            })
        }
    }
}
