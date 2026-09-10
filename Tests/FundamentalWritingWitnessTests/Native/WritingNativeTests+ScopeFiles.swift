import AppKit
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("every scoped block reopens from an owned document record")
    func nativeScopeFiles() async throws
    {
        let files = try WritingFileFixture()
        let traits = Set(WritingInlineFixture.traits)
        let groups = try (0 ..< 3).map
        {
            form in
            try WritingInlineFixture.roles([
                WritingScopeFixture.run("e\u{301} Native 😀", form: form,
                                         traits: traits)
            ])
        }
        let blocks = groups.flatMap { $0 }
        let window = try WritingTestWindow(session: DocumentSession(
            state: WritingTestDocument(blocks: blocks).state
        ))
        defer
        {
            window.close()
            files.remove()
        }
        let location = try #require(DocumentFileLocation(
            files.directory.appending(path: "All Scopes.fun")
        ))
        try await window.controller.fileOwner.save(to: location)
        let owner = try await WritingFileOwner.open(location)
        #expect(owner.session.document == window.session.document)
        let reopened = try WritingTestWindow(owner: owner)
        defer
        {
            reopened.close()
        }
        #expect(reopened.view.string.utf16.elementsEqual(
            window.view.string.utf16
        ))
        let projection = reopened.controller.bridge.projection
        let storage = try #require(reopened.view.textStorage)
        var ordinal = 0
        for (index, block) in blocks.enumerated()
        {
            let base = try #require(WritingTypography.attributes(
                for: block, ordinal: &ordinal
            )?[.font] as? NSFont)
            let actual = storage.attributes(
                at: projection.map.spans[index].range.location,
                effectiveRange: nil
            )
            WritingScopeFixture.expect(index / groups[0].count, in: actual)
            try WritingInlineFixture.expect(traits, in: actual, base: base)
        }
        #expect(!reopened.session.isDirty)
    }
}
