import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("link lookup covers every admitted role without linking separators")
    func linkOpeningRoles() throws
    {
        let linked = try WritingScopeFixture.run("Ae\u{301}😀", form: 2)
        let blocks = try WritingInlineFixture.roles([linked])
        let source = try WritingTestDocument(blocks: blocks)
        let projection = try source.projection()
        for span in projection.map.spans
        {
            let lower = span.range.location
            let upper = lower + span.range.length
            for index in lower ..< upper
            {
                #expect(projection.link(at: index)?.value.utf16.elementsEqual(
                    WritingScopeFixture.link.utf16
                ) == true)
            }
            for index in upper ..< upper + span.separatorLength
            {
                #expect(projection.link(at: index) == nil)
            }
        }
    }

    @Test("uniform targets ignore traits and language but preserve spelling")
    func linkOpeningRunAgreement() throws
    {
        let first = try WritingScopeFixture.run("A", form: 0)
        let last = try WritingScopeFixture.run("B", form: 2, traits: [.strong])
        let source = try WritingTestDocument(blocks: [.paragraph(.init(runs: [
            first, SemanticRun(text: ""), last
        ]))], start: 2, end: 0)
        #expect(try source.projection().selectedLink?.value ==
            WritingScopeFixture.link)
        let alternate = try #require(SemanticLinkDestination(
            " https://example.invalid/é "
        ))
        let changed = SemanticRun(text: "B", attributes: .scoped(
            traits: [], scopes: .link(alternate)
        ))
        let mixed = try WritingTestDocument(blocks: [.paragraph(.init(runs: [
            first, changed
        ]))], start: 2, end: 0)
        #expect(try mixed.projection().selectedLink == nil)
    }
}
