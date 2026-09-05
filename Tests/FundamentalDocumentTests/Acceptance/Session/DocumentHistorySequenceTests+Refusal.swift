import Testing

@testable import FundamentalDocument

extension DocumentHistorySequenceTests
{
    @Test
    func staleAndInvalidEditsRetainAUsableRedoBranch() throws
    {
        let driver = SessionHistoryTestDriver(
            try SessionTestDocument(texts: ["😀A"])
        )
        try driver.insert("X", at: 2)
        let oldObservation = driver.session.observation
        try driver.move(.undo)
        let retained = driver.storage
        let valid = try SessionTestEdit.inserted("Y", at: driver.point(2))
        #expect(driver.session.submit(.edit(oldObservation, valid)) ==
            .refused(.staleObservation))
        let deletion = try #require(SemanticTextDeletion(
            range: driver.range(1, 2)
        ))
        let invalid = [
            try SessionTestEdit.inserted("Y", at: driver.point(1)),
            try SessionTestEdit.inserted("\r\n", at: driver.point(2)),
            CanonicalDocumentEdit.text(.deletion(deletion))
        ]
        for edit in invalid
        {
            #expect(driver.session.submit(.edit(
                driver.session.observation,
                edit
            )) == .refused(.invalidCommand))
            #expect(driver.storage == retained)
        }
        #expect(driver.session.submit(.select(
            driver.session.observation,
            .caret(at: try driver.point(1))
        )) == .refused(.invalidCommand))
        #expect(driver.storage == retained)
        try driver.move(.redo)
        try driver.expect("😀XA", revision: 11, generation: 6)
        #expect(retained.history.redo.count == 1)
    }
}
