struct DocumentHistoryLimits: Equatable, Sendable
{
    let transactions: Int
    let retainedUTF16Units: Int

    init()
    {
        transactions = 64
        retainedUTF16Units = 134_217_728
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
