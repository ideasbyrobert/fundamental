package struct LayoutRequest: Equatable, Sendable
{
    package let generation: UInt64
    package let parameters: LayoutParameters

    package init?(
        generation: UInt64,
        width: Double,
        blockSpacing: Double,
        rowSpacing: Double,
        columnSpacing: Double,
        cellPadding: Double
    )
    {
        guard let parameters = LayoutParameters(
            width: width,
            blockSpacing: blockSpacing,
            rowSpacing: rowSpacing,
            columnSpacing: columnSpacing,
            cellPadding: cellPadding
        )
        else
        {
            return nil
        }
        self.generation = generation
        self.parameters = parameters
    }
}
