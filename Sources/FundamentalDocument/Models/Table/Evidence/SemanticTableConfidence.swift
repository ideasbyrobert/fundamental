struct SemanticTableConfidence: Equatable, Sendable
{
    let value: Double

    init?(_ value: Double)
    {
        guard value.isFinite,
              value >= 0,
              value <= 1
        else
        {
            return nil
        }

        self.value = value
    }
}
