import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingMixedDocumentFixture
{
    static func edit(_ window: WritingTestWindow) throws
    {
        for index in 0 ..< roleCount
        {
            let projection = try #require(WritingProjection(
                window.session.state
            ))
            let span = projection.map.spans[index]
            window.select(span.range.location + 1)
            let before = window.session.document
            try window.key("z", code: 6)
            try expect(window.session, edited: index + 1)
            #expect(window.session.document.revision.value
                == before.revision.value + 1)
            let responder = try #require(
                window.controller.documentWindow.firstResponder
            )
            #expect(responder.tryToPerform(
                #selector(WritingTextView.undoCanonicalEdit), with: nil
            ))
            try expect(window.session, edited: index)
            #expect(window.session.history.redo.count == 1)
            #expect(responder.tryToPerform(
                #selector(WritingTextView.redoCanonicalEdit), with: nil
            ))
            try expect(window.session, edited: index + 1)
            #expect(window.session.history.redo.isEmpty)
            #expect(window.session.document.revision.value
                == before.revision.value + 3)
            try accessible(window)
        }
    }

    static func accessible(_ window: WritingTestWindow) throws
    {
        let projection = try #require(WritingProjection(window.session.state))
        try window.expect(projection.text, selection: projection.selection)
        let text = try #require(window.view.accessibilityValue())
        #expect(text.utf16.elementsEqual(projection.text.utf16))
        #expect(window.view.accessibilityNumberOfCharacters()
            == projection.text.utf16.count)
        #expect(window.view.accessibilitySelectedTextRange()
            == projection.selection)
    }

    static func captureWriter(
        _ window: WritingTestWindow, name: String
    ) throws
    {
        try styledWriter(window)
        let projection = try #require(WritingProjection(window.session.state))
        for index in [0, 10]
        {
            window.view.scrollRangeToVisible(projection.map.spans[index].range)
            let bitmap = try WritingWindowCapture.capture(window)
            try WritingWindowCapture.export(
                bitmap, name: "\(name)-block-\(index)"
            )
        }
    }
}
