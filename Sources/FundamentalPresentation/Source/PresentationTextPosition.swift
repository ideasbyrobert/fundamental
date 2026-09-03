package struct PresentationTextPosition: Equatable, Sendable
{
    package let residentID: PresentationResidentID
    package let sourcePoint: PresentationTextPoint

    package init(
        residentID: PresentationResidentID,
        sourcePoint: PresentationTextPoint
    )
    {
        self.residentID = residentID
        self.sourcePoint = sourcePoint
    }
}
