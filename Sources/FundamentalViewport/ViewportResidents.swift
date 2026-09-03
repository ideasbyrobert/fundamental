package struct ViewportResidents: Equatable, Sendable
{
    package let first: ResidentLayoutFragment
    package let remaining: [ResidentLayoutFragment]

    package var all: [ResidentLayoutFragment]
    {
        [first] + remaining
    }
}
