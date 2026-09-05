struct DocumentHistoryLimits: Equatable, Sendable
{
    let transactions: Int
    let retainedUTF16Units: Int

    init()
    {
        transactions = 64
        retainedUTF16Units = 1_048_576
    }

    init?(transactions: Int, retainedUTF16Units: Int)
    {
        guard transactions > 0, retainedUTF16Units > 0
        else
        {
            return nil
        }
        self.transactions = transactions
        self.retainedUTF16Units = retainedUTF16Units
    }
}
