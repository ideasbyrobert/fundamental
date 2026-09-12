import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalStorage
@testable import FundamentalWritingWitness

extension WritingTextInterchangeTests
{
    @Test("import creates an unsaved owner and never modifies its source")
    func importedOwner() async throws
    {
        let directory = try WritingRecoveryTests.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let location = directory.appending(path: "Draft.txt")
        let bytes = Data("# Literal\r\nМир\t👨‍👩‍👧‍👦\n".utf8)
        try bytes.write(to: location)
        let owner = try await WritingFileOwner.importText(location)
        #expect(owner.displayName == "Draft")
        #expect(owner.binding == nil)
        #expect(owner.session.isDirty)
        #expect(!owner.session.canUndo)
        #expect(try Data(contentsOf: location) == bytes)
        let exported = try WritingTextExport.data(from: owner.session.document)
        #expect(exported == bytes)
        let invalid = directory.appending(path: "Invalid.txt")
        try Data([0xC0, 0xAF]).write(to: invalid)
        await #expect(throws: WritingTextFailure.invalidUTF8)
        {
            try await WritingFileOwner.importText(invalid)
        }
    }

    @Test("exports and failed exports retain binding, history and dirty state")
    func exportOwnership() async throws
    {
        let directory = try WritingRecoveryTests.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("Original").state
        ))
        let native = try #require(DocumentFileLocation(
            directory.appending(path: "Draft.fun")
        ))
        try await owner.save(to: native)
        let saved = try Data(contentsOf: native.url)
        let initial = try #require(WritingProjection(owner.session.state))
        let edit = try #require(WritingTextProposal(
            ranges: [initial.selection], replacements: ["New "], in: initial
        ))
        owner.session.submit(edit.command)
        let state = owner.session.state
        let binding = owner.binding
        let history = owner.session.history
        let exported = directory.appending(path: "Draft.txt")
        try await owner.exportText(to: exported)
        #expect(try Data(contentsOf: exported) == Data("New Original".utf8))
        #expect(owner.session.isDirty)
        #expect(owner.session.state == state)
        #expect(owner.session.history == history)
        #expect(owner.binding?.location == binding?.location)
        #expect(owner.binding?.revision == binding?.revision)
        await #expect(throws: WritingTextFailure.invalidLocation)
        {
            try await owner.exportText(to: native.url)
        }
        let impossible = exported.appending(path: "Impossible.txt")
        await #expect(throws: (any Error).self)
        {
            try await owner.exportText(to: impossible)
        }
        #expect(try Data(contentsOf: native.url) == saved)
        #expect(owner.session.isDirty)
        #expect(owner.session.state == state)
        #expect(owner.session.history == history)
        #expect(owner.binding?.location == binding?.location)
        #expect(owner.binding?.revision == binding?.revision)
    }
}
