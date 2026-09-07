import FundamentalStorage

extension WritingFileOwner
{
    func save(to location: DocumentFileLocation) async throws
    {
        guard !isSaving
        else
        {
            throw WritingFileFailure.busy
        }
        let condition: DocumentFileWriteCondition
        if let binding, binding.location == location
        {
            condition = .unchanged(binding.revision)
        }
        else
        {
            condition = .absent
        }
        let ticket = session.prepareSave()
        didChange?()
        defer
        {
            didChange?()
        }
        do
        {
            let receipt = try await storage.save(
                ticket.document, at: location, condition: condition
            )
            binding = WritingFileBinding(receipt.file)
            retainedItems = receipt.retainedItems
            guard session.acknowledgeSave(ticket)
            else
            {
                throw WritingFileFailure.acknowledgementRefused
            }
        }
        catch
        {
            if case let DocumentFileFailure.unconfirmedWrite(recovery) = error
            {
                retainedItems = recovery.locations
            }
            session.abandonSave(ticket)
            throw error
        }
    }
}
