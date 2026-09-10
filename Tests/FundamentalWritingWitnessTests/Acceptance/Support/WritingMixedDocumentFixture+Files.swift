import AppKit
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingMixedDocumentFixture
{
    static func reopen(
        _ session: DocumentSession, suffix: String
    ) async throws -> DocumentSnapshot
    {
        let files = try WritingFileFixture()
        defer { files.remove() }
        let location = try #require(DocumentFileLocation(
            files.directory.appending(path: "Mixed." + suffix)
        ))
        let fileOwner = WritingFileOwner(session: session)
        try await fileOwner.save(to: location)
        #expect(!session.isDirty)
        let reopened = try await WritingFileOwner.open(location)
        #expect(reopened.session.document == session.document)
        #expect(!reopened.session.isDirty)
        #expect(reopened.session.history.undo.isEmpty)
        #expect(reopened.session.history.redo.isEmpty)
        weak var discarded: WritingNativeBridge?
        let source = try autoreleasepool
        {
            let window = try WritingTestWindow(owner: reopened)
            defer { window.close() }
            discarded = window.controller.bridge
            try WritingTestApplication.activate(window.controller)
            try accessible(window)
            try captureWriter(window, name: "mixed-reopened-" + suffix)
            return reopened.session.state.snapshot
        }
        #expect(discarded == nil)
        return source
    }
}
