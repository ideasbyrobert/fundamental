enum WritingMeasurementLocation: String, CaseIterable, Sendable
{
    case start
    case middle
    case end

    func block(in count: Int) -> Int
    {
        switch self
        {
        case .start:
            0
        case .middle:
            count / 2
        case .end:
            count - 1
        }
    }
}
