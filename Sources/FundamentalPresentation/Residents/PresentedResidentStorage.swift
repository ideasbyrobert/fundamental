package final class PresentedResidentStorage: Equatable, Sendable
{
    package let residentID: PresentationResidentID
    package let frame: PresentationRectangle
    package let content: PresentedResidentContent
    package let marks: [PresentationMark]

    package init(
        residentID: PresentationResidentID,
        frame: PresentationRectangle,
        content: PresentedResidentContent,
        marks: [PresentationMark]
    )
    {
        self.residentID = residentID
        self.frame = frame
        self.content = content
        self.marks = marks
    }

    package static func == (
        lhs: PresentedResidentStorage,
        rhs: PresentedResidentStorage
    ) -> Bool
    {
        lhs.residentID == rhs.residentID
            && lhs.frame == rhs.frame
            && lhs.content == rhs.content
            && lhs.marks == rhs.marks
    }
}
