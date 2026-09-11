package enum ParagraphFitness: Int, CaseIterable, Sendable
{
    case tight
    case normal
    case loose
    case veryLoose
    case ragged

    init(ratio: Double)
    {
        if ratio < -0.5
        {
            self = .tight
        }
        else if ratio <= 0.5
        {
            self = .normal
        }
        else if ratio <= 0.8
        {
            self = .loose
        }
        else
        {
            self = .veryLoose
        }
    }
}
