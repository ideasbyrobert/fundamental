package final class PresentedDocumentStorage: Equatable, Sendable
{
    package let plane: PresentationDocumentPlane
    package let sourceAnchor: PresentationSourceAnchor
    package let residents: PresentedResidentCollection
    package let marks: [PresentationMark]

    package init(
        plane: PresentationDocumentPlane,
        sourceAnchor: PresentationSourceAnchor,
        residents: PresentedResidentCollection,
        marks: [PresentationMark]
    )
    {
        self.plane = plane
        self.sourceAnchor = sourceAnchor
        self.residents = residents
        self.marks = marks
    }

    package static func == (
        lhs: PresentedDocumentStorage,
        rhs: PresentedDocumentStorage
    ) -> Bool
    {
        lhs.plane == rhs.plane
            && lhs.sourceAnchor == rhs.sourceAnchor
            && lhs.residents == rhs.residents
            && lhs.marks == rhs.marks
    }
}
