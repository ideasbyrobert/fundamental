package struct PresentedResident: Equatable, Sendable
{
    package let residence: PresentationResidence
    let storage: PresentedResidentStorage

    package init(
        residence: PresentationResidence,
        storage: PresentedResidentStorage
    )
    {
        self.residence = residence
        self.storage = storage
    }

    package var residentID: PresentationResidentID
    {
        storage.residentID
    }

    package var frame: PresentationRectangle
    {
        storage.frame
    }

    package var content: PresentedResidentContent
    {
        storage.content
    }

    package var marks: [PresentationMark]
    {
        storage.marks
    }

    package static func == (
        lhs: PresentedResident,
        rhs: PresentedResident
    ) -> Bool
    {
        lhs.residence == rhs.residence
            && lhs.storage == rhs.storage
    }
}
