import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite("Literal text interchange", .serialized)
struct WritingTextInterchangeTests
{
    @Test("text spelling survives import and export", arguments: [
        "", "\t\n\n", "# Heading\n- literal text\n",
        "Мир e\u{301} 👨‍👩‍👧‍👦\n", "Windows\r\n\r\nLines\r\n",
        "Classic\rMac\r", "Mixed\r\r\n\n\r\nEnd",
        "Interior \u{FEFF} marker\t\u{0000} end"
    ])
    func spelling(_ text: String) throws
    {
        let imported = try WritingTextImport(Data(text.utf8))
        let projection = try #require(WritingProjection(imported.state))
        #expect(Array(projection.text.utf16) == Array(text.utf16))
        let document = projection.snapshot.snapshot.document
        #expect(try WritingTextExport.data(from: document) == Data(text.utf8))
        #expect(document.content.blocks.allSatisfy
        {
            if case .paragraph = $0.block { true } else { false }
        })
        let session = DocumentSession(state: imported.state)
        #expect(session.isDirty)
        #expect(!session.canUndo)
        #expect(projection.selection == NSRange(location: 0, length: 0))
    }

    @Test("one leading BOM is consumed and later BOMs remain content")
    func byteOrderMark() throws
    {
        let bom = Data([0xEF, 0xBB, 0xBF])
        for text in ["", "Text", "\u{FEFF}Text\u{FEFF}"]
        {
            let imported = try WritingTextImport(bom + Data(text.utf8))
            let projection = try #require(WritingProjection(imported.state))
            #expect(Array(projection.text.utf16) == Array(text.utf16))
        }
    }

    @Test("malformed UTF-8 is refused without replacement characters",
          arguments: [[UInt8]]([
            [0x80], [0xC0, 0xAF], [0xE2, 0x82], [0xED, 0xA0, 0x80],
            [0xF4, 0x90, 0x80, 0x80], [0xFF, 0xFE, 0x41, 0x00]
          ]))
    func invalidEncoding(_ bytes: [UInt8])
    {
        #expect(throws: WritingTextFailure.invalidUTF8)
        {
            try WritingTextImport(Data(bytes))
        }
    }

    @Test("native capacity is preflighted before importing")
    func capacity()
    {
        let limit = WritingSurfacePolicy.maximumUTF16Units
        for text in [String(repeating: "a", count: limit + 1),
                     String(repeating: "\n", count:
                        WritingSurfacePolicy.maximumParagraphs)]
        {
            #expect(throws: WritingTextFailure.excessiveText)
            {
                try WritingTextImport(Data(text.utf8))
            }
        }
        #expect(throws: WritingTextFailure.excessiveText)
        {
            try WritingTextImport(Data(repeating: 0x61,
                count: WritingTextImport.maximumBytes + 1))
        }
    }
}
