import Testing

@testable import FundamentalDocument

extension DocumentSessionHistoryTests
{
    @Test
    func capacityRefusalRetainsStateAndViableRedo() throws
    {
        let limits = try #require(DocumentHistoryLimits(
            transactions: 64,
            retainedUTF16Units: 3
        ))
        let driver = SessionHistoryTestDriver(
            try SessionTestDocument(texts: ["A"]),
            limits: limits
        )
        try driver.insert("B", at: 1)
        try driver.move(.undo)
        let retained = driver.storage
        let edit = try SessionTestEdit.inserted("CCC", at: driver.point(1))
        #expect(driver.session.submit(.edit(driver.session.observation, edit))
            == .refused(.historyCapacity))
        #expect(driver.storage == retained)
        try driver.expect("A", revision: 10, generation: 5)
        try driver.move(.redo)
        try driver.expect("AB", revision: 11, generation: 6)
    }
}
