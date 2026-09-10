import AppKit
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("scope sheets keep two owned document windows independent")
    func scopeControlsSheetFiles() async throws
    {
        let files = try WritingFileFixture()
        defer
        {
            files.remove()
        }
        let first = try WritingTestWindow(session: DocumentSession(
            state: #require(WritingDocumentSeed()).state
        ))
        defer
        {
            first.close()
        }
        let link = try first.openScopeSheet(.link)
        first.setScopeValue(WritingScopeFixture.link, in: link)
        try await first.finishScopeSheet(link,
                                         response: .alertFirstButtonReturn)
        try first.key("x", code: 7)
        try await first.controller.fileOwner.save(to: files.location)
        let original = first.session.document
        let pending = try first.openScopeSheet(.link)
        first.setScopeValue("Cancelled", in: pending)
        let second = try WritingTestWindow(session: DocumentSession(
            state: #require(WritingDocumentSeed()).state
        ))
        defer
        {
            second.close()
        }
        #expect(first.session.document.documentID !=
            second.session.document.documentID)
        let language = try second.openScopeSheet(.language, toolbar: true)
        second.setScopeValue(WritingScopeFixture.language, in: language)
        try await second.finishScopeSheet(language,
                                           response: .alertFirstButtonReturn)
        try second.key("y", code: 16)
        let location = try #require(DocumentFileLocation(
            files.directory.appending(path: "Second.fun")
        ))
        try await second.controller.fileOwner.save(to: location)
        let retained = second.storage
        try await first.finishScopeSheet(pending,
                                          response: .alertSecondButtonReturn)
        #expect(first.session.document == original && !first.session.isDirty)
        #expect(second.storage == retained && !second.session.isDirty)
        for (index, pair) in [(first, files.location), (second, location)]
            .enumerated()
        {
            let owner = try await WritingFileOwner.open(pair.1)
            #expect(owner.session.document == pair.0.session.document)
            let expected = try WritingScopeFixture.run("", form: index)
            #expect(try WritingInlineFixture.runs(owner.session.document)
                .allSatisfy { $0.attributes == expected.attributes })
        }
    }
}
