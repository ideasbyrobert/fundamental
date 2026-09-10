import AppKit
import Testing

@testable import FundamentalWritingWitness
@testable import FundamentalDocument

extension WritingTestWindow
{
    static func linked() throws -> Self
    {
        let run = try WritingScopeFixture.run("Ae\u{301}😀Z", form: 2,
                                              traits: [.strong])
        let source = try WritingTestDocument(blocks: [
            .paragraph(.init(runs: [run]))
        ])
        return try Self(session: DocumentSession(state: source.state,
                                                   initiallySaved: true))
    }

    static func refuseUnexpectedLink(_ url: URL) -> Bool
    {
        Issue.record("Unexpected link opening: \(url.absoluteString)")
        return true
    }

    func openLinkChoice() throws -> NSMenuItem
    {
        let menu = try #require(controller.formatting.text.menu)
        menu.delegate?.menuNeedsUpdate?(menu)
        return try #require(menu.items.first
            { $0.identifier == WritingOpenLinkMenu.identifier })
    }
}
