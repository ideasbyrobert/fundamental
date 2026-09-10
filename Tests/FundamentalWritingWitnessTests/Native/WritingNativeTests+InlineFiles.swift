import AppKit
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("all native inline traits reopen from exact owned document records")
    func nativeInlineFiles() async throws
    {
        let files = try WritingFileFixture()
        let traits = Set(WritingInlineFixture.traits)
        let blocks = try WritingInlineFixture.roles([
            SemanticRun(text: "e\u{301} Native 😀", traits: traits)
        ])
        let window = try WritingTestWindow(session: DocumentSession(
            state: WritingTestDocument(blocks: blocks).state
        ))
        defer
        {
            window.close()
            files.remove()
        }
        for name in ["Inline.fun", "Inline.fundamental"]
        {
            let location = try #require(DocumentFileLocation(
                files.directory.appending(path: name)
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
                let attributes = storage.attributes(
                    at: projection.map.spans[index].range.location,
                    effectiveRange: nil
                )
                try WritingInlineFixture.expect(traits, in: attributes,
                                                 base: base)
            }
            #expect(!reopened.session.isDirty)
        }
    }
}
