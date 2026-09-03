package struct PresentationPalette: Equatable, Sendable
{
    package let documentBackground: PresentationColor
    package let tableBackground: PresentationColor
    package let headerBackground: PresentationColor
    package let rule: PresentationColor
    package let text: PresentationColor
    package let decoration: PresentationColor

    package init?(
        documentBackground: PresentationColor,
        tableBackground: PresentationColor,
        headerBackground: PresentationColor,
        rule: PresentationColor,
        text: PresentationColor,
        decoration: PresentationColor
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

    package var colorSpace: PresentationColorSpaceIdentity
    {
        documentBackground.colorSpace
    }
}
