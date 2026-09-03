package struct PresentedDocument: Equatable, Sendable
{
    package let lineage: PresentationLineage
    let storage: PresentedDocumentStorage

    package init(
        lineage: PresentationLineage,
        storage: PresentedDocumentStorage
    )
    {
        self.lineage = lineage
        self.storage = storage
    }

    package var plane: PresentationDocumentPlane
    {
        storage.plane
    }

    package var sourceAnchor: PresentationSourceAnchor
    {
        storage.sourceAnchor
    }

    package var residents: PresentedResidentCollection
    {
        storage.residents
    }

    package var marks: [PresentationMark]
    {
        storage.marks
    }

    package static func == (
        lhs: PresentedDocument,
        rhs: PresentedDocument
    ) -> Bool
    {
        lhs.lineage == rhs.lineage
            && lhs.storage == rhs.storage
    }
}
