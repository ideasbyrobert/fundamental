import Foundation
import Testing

@testable import FundamentalDocument

extension DocumentSessionSaveTests
{
    @Test("equal looking Unicode stays dirty until its own spelling is saved")
    func exactSpelling() throws
    {
        let driver = SessionHistoryTestDriver(
            try SessionTestDocument(texts: ["é"])
        )
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let before = driver.session.prepareSave()
        let originalBytes = try codec.encode(before.document)
        #expect(driver.session.acknowledgeSave(before))
        let insertion = try #require(SemanticInsertion(
            text: "e\u{301}", attributes: .direct(traits: [])
        ))
        let replacement = try #require(SemanticTextReplacement(
            range: driver.range(0, 1), insertion: insertion
        ))
        try driver.edit(.text(.replacement(replacement)))
        #expect(driver.session.document.content == before.document.content)
        #expect(driver.session.isDirty)
        #expect(try codec.encode(before.document) == originalBytes)
        let after = driver.session.prepareSave()
        #expect(driver.session.acknowledgeSave(after))
        #expect(!driver.session.isDirty)
        try driver.move(.undo)
        #expect(driver.session.isDirty)
        #expect(try spelling(driver.session.document) == Array("é".utf8))
        try driver.move(.redo)
        #expect(!driver.session.isDirty)
        #expect(try spelling(driver.session.document) == Array("e\u{301}".utf8))
    }

    private func spelling(_ document: CanonicalDocument) throws -> [UInt8]
    {
        let block = try #require(document.content.blocks.first)
        let editable = try #require(EditableSemanticBlock(block.block))
        return Array(editable.runs.map(\.text).joined().utf8)
    }
}
