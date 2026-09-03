package struct RasterPalette: Equatable, Sendable
{
    package let documentBackground: RasterColor
    package let tableBackground: RasterColor
    package let headerBackground: RasterColor
    package let rule: RasterColor
    package let text: RasterColor
    package let decoration: RasterColor

    package init?(
        documentBackground: RasterColor,
        tableBackground: RasterColor,
        headerBackground: RasterColor,
        rule: RasterColor,
        text: RasterColor,
        decoration: RasterColor
    )
    {
        let colors = [
            documentBackground,
            tableBackground,
            headerBackground,
            rule,
            text,
            decoration
        ]
        guard colors.allSatisfy(
            { $0.colorSpace == documentBackground.colorSpace }
        )
        else
        {
            return nil
        }
        self.documentBackground = documentBackground
        self.tableBackground = tableBackground
        self.headerBackground = headerBackground
        self.rule = rule
        self.text = text
        self.decoration = decoration
    }

    package var colorSpace: RasterColorSpaceIdentity
    {
        documentBackground.colorSpace
    }
}
