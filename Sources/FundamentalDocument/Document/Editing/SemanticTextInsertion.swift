struct SemanticTextInsertion: Equatable, Sendable
{
    let point: DocumentPoint
    let insertion: SemanticInsertion

    init(
        point: DocumentPoint,
        insertion: SemanticInsertion
    )
    {
        self.point = point
        self.insertion = insertion
    }
}
