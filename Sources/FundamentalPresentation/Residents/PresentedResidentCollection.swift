package struct PresentedResidentCollection: Equatable, Sendable
{
    package let first: PresentedResident
    package let remaining: [PresentedResident]

    package var all: [PresentedResident]
    {
        [first] + remaining
    }
}
