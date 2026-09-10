import AppKit
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("two owned documents retain independent scoped input and saved state")
    func nativeScopeFileIsolation() async throws
    {
        let files = try WritingFileFixture()
        let first = try WritingTestWindow(session: DocumentSession(
            state: #require(WritingDocumentSeed()).state
        ))
        let second = try WritingTestWindow(session: DocumentSession(
            state: #require(WritingDocumentSeed()).state
        ))
        defer
        {
            first.close()
            second.close()
            files.remove()
        }
        #expect(first.session.document.documentID !=
            second.session.document.documentID)
        let windows = [first, second]
        let forms = [0, 2]
        for (index, window) in windows.enumerated()
        {
            try WritingScopeFixture.choose(forms[index], in: window)
            window.commit("Document \(index): e\u{301} 😀")
            let location = try #require(DocumentFileLocation(
                files.directory.appending(path: "Scope-\(index).fun")
            ))
            try await window.controller.fileOwner.save(to: location)
            let owner = try await WritingFileOwner.open(location)
            #expect(owner.session.document == window.session.document)
            let expected = try WritingScopeFixture.run("", form: forms[index])
            let runs = try WritingInlineFixture.runs(owner.session.document)
            #expect(runs.filter { !$0.text.isEmpty }.allSatisfy
                { $0.attributes == expected.attributes })
        }
        let untouched = second.storage
        first.commit("X")
        #expect(first.session.isDirty)
        #expect(second.storage == untouched && !second.session.isDirty)
        let location = try #require(DocumentFileLocation(
            files.directory.appending(path: "Scope-0.fun")
        ))
        let saved = try await WritingFileOwner.open(location)
        #expect(saved.session.document != first.session.document)
        #expect(saved.session.document.documentID ==
            first.session.document.documentID)
    }
}
