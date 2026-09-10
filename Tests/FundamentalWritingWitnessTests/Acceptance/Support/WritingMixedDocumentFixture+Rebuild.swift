import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingMixedDocumentFixture
{
    static func editedSession() throws -> DocumentSession
    {
        let fixture = try document()
        let session = DocumentSession(state: fixture.state)
        weak var discarded: WritingNativeBridge?
        let retained = try autoreleasepool
        {
            let window = try WritingTestWindow(session: session)
            defer { window.close() }
            discarded = window.controller.bridge
            try edit(window)
            try captureWriter(window, name: "mixed-edited")
            let retained = window.storage
            window.view.delegate = nil
            window.view.string = ""
            #expect(window.view.string.isEmpty)
            #expect(window.storage == retained)
            return retained
        }
        #expect(discarded == nil)
        try autoreleasepool
        {
            let rebuilt = try WritingTestWindow(session: session)
            defer { rebuilt.close() }
            #expect(rebuilt.storage == retained)
            try accessible(rebuilt)
            rebuilt.view.undoCanonicalEdit(nil)
            try expect(session, edited: roleCount - 1)
            rebuilt.view.redoCanonicalEdit(nil)
            try expect(session, edited: roleCount)
            try accessible(rebuilt)
            try captureWriter(rebuilt, name: "mixed-rebuilt")
        }
        return session
    }
}
