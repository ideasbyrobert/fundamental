import Testing

@testable import FundamentalDocument

extension DocumentSessionHistoryTests
{
    @Test
    func allObservationFieldsFenceBothHistoryDirections() throws
    {
        let driver = SessionHistoryTestDriver(try SessionTestDocument())
        try driver.insert("X", at: 1)
        try driver.insert("Y", at: 2)
        try driver.move(.undo)
        let retained = driver.storage
        let invalid = [
            try SessionTestDocument(revision: 11, generation: 6, marker: 9),
            try SessionTestDocument(revision: 10, generation: 6),
            try SessionTestDocument(revision: 11, generation: 5)
        ]
        #expect(driver.session.canUndo && driver.session.canRedo)
        for fixture in invalid
        {
            for direction in [DocumentHistoryDirection.undo, .redo]
            {
                #expect(driver.session.submit(DocumentHistoryCommand(
                    observation: fixture.observation,
                    direction: direction
                )) == .refused(.staleObservation))
                #expect(driver.storage == retained)
            }
        }
    }

    @Test
    func historyRefusesExhaustedCountersAtomically() throws
    {
        let fixtures = [
            try SessionTestDocument(revision: UInt64.max - 1),
            try SessionTestDocument(generation: UInt64.max - 1)
        ]
        let reasons: [DocumentSessionRefusal] = [
            .invalidCommand, .generationExhausted
        ]
        for (fixture, reason) in zip(fixtures, reasons)
        {
            let driver = SessionHistoryTestDriver(fixture)
            try driver.insert("X", at: 1)
            let retained = driver.storage
            #expect(driver.session.submit(DocumentHistoryCommand(
                observation: driver.session.observation,
                direction: .undo
            )) == .refused(reason))
            #expect(driver.storage == retained)
            #expect(driver.session.canUndo)
        }
    }
}
