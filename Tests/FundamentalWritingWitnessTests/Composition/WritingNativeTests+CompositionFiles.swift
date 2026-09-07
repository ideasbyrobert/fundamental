import AppKit
import FundamentalStorage
import Testing

@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("saving accepts marked text before freezing the owned file")
    func save() async throws
    {
        let fixture = try WritingFileFixture()
        let window = try WritingTestWindow("A")
        defer
        {
            window.close()
            fixture.remove()
        }
        try await window.controller.fileOwner.save(to: fixture.location)
        window.select(1)
        window.mark("é")
        #expect(!window.session.isDirty)
        #expect(await window.controller.performSave(
            choosingLocation: false, closing: false
        ))
        #expect(!window.view.hasMarkedText())
        #expect(!window.session.isDirty)
        let reopened = try await WritingFileOwner.open(fixture.location)
        #expect(WritingProjection(reopened.session.state)?.text == "Aé")
        try window.expect("Aé", selection: NSRange(location: 2, length: 0))
    }

    @Test("closing a clean file with preedit requests a dirty-file decision")
    func close() async throws
    {
        let fixture = try WritingFileFixture()
        let window = try WritingTestWindow("A")
        defer
        {
            window.close()
            fixture.remove()
        }
        try await window.controller.fileOwner.save(to: fixture.location)
        window.select(1)
        window.mark("é")
        #expect(!window.controller.mayClose())
        #expect(window.session.isDirty)
        #expect(window.controller.documentWindow.isVisible)
        #expect(!window.view.hasMarkedText())
        try window.expect("Aé", selection: NSRange(location: 2, length: 0))
        let reopened = try await WritingFileOwner.open(fixture.location)
        #expect(WritingProjection(reopened.session.state)?.text == "A")
    }
}
