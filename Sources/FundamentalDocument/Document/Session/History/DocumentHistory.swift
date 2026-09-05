struct DocumentHistory: Equatable, Sendable
{
    let limits: DocumentHistoryLimits
    let undo: [DocumentHistoryTransaction]
    let redo: [DocumentHistoryTransaction]
    let retainedUTF16Units: Int

    init(limits: DocumentHistoryLimits = DocumentHistoryLimits())
    {
        self.limits = limits
        undo = []
        redo = []
        retainedUTF16Units = 0
    }

    init?(
        recording transaction: DocumentHistoryTransaction,
        in history: DocumentHistory
    )
    {
        let capacity = history.limits.retainedUTF16Units
        let cost = transaction.retainedUTF16Units
        guard cost <= capacity
        else
        {
            return nil
        }
        var remaining = history.undo[...]
        var count = remaining.reduce(0)
        {
            $0 + $1.retainedUTF16Units
        }
        while remaining.count >= history.limits.transactions ||
              count > capacity - cost
        {
            guard let oldest = remaining.first
            else
            {
                return nil
            }
            count -= oldest.retainedUTF16Units
            remaining = remaining.dropFirst()
        }
        limits = history.limits
        undo = Array(remaining) + [transaction]
        redo = []
        retainedUTF16Units = count + cost
    }

    init?(
        moving direction: DocumentHistoryDirection,
        in history: DocumentHistory
    )
    {
        switch direction
        {
        case .undo:
            guard let transaction = history.undo.last
            else
            {
                return nil
            }
            undo = Array(history.undo.dropLast())
            redo = history.redo + [transaction]
        case .redo:
            guard let transaction = history.redo.last
            else
            {
                return nil
            }
            undo = history.undo + [transaction]
            redo = Array(history.redo.dropLast())
        }
        limits = history.limits
        retainedUTF16Units = history.retainedUTF16Units
    }
}
