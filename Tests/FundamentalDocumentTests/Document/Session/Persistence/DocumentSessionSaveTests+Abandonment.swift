import Testing

@testable import FundamentalDocument

extension DocumentSessionSaveTests
{
    @Test("abandonment invalidates its request without acknowledging content")
    func abandonedSave() throws
    {
        let session = DocumentSession(state: try SessionTestDocument().state)
        let older = session.prepareSave()
        let latest = session.prepareSave()
        #expect(!session.abandonSave(older))
        #expect(session.hasPendingSave)
        #expect(session.abandonSave(latest))
        #expect(!session.hasPendingSave)
        #expect(session.isDirty)
        #expect(!session.acknowledgeSave(latest))
        #expect(!session.acknowledgeSave(older))
        #expect(!session.abandonSave(latest))
    }

    @Test("another session cannot abandon the current owner's pending save")
    func foreignAbandonment() throws
    {
        let fixture = try SessionTestDocument()
        let first = DocumentSession(state: fixture.state)
        let second = DocumentSession(state: fixture.state)
        let a = first.prepareSave()
        let b = second.prepareSave()
        #expect(!first.abandonSave(b))
        #expect(!second.abandonSave(a))
        #expect(first.hasPendingSave && second.hasPendingSave)
        #expect(first.acknowledgeSave(a))
        #expect(second.acknowledgeSave(b))
    }
}
