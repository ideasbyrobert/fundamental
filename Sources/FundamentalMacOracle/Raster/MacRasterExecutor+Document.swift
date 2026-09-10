import FundamentalPresentation

extension MacRasterExecutor
{
    func admit(
        _ document: PresentedDocument
    ) -> MacAdmittedDocumentExecution?
    {
        guard let colorSpace = MacAdmittedColorSpace(
            document.plane.colorSpace
        ),
              let background = MacAdmittedColor(
                  document.plane.palette.documentBackground,
                  colorSpace: colorSpace
              )
        else
        {
            return nil
        }
        let origins = Self.lineOrigins(document.residents)
        var marks: [MacAdmittedRasterMark] = []
        marks.reserveCapacity(document.marks.count)
        for mark in document.marks
        {
            guard let admitted = admit(
                mark, origins: origins, colorSpace: colorSpace
            )
            else
            {
                return nil
            }
            marks.append(admitted)
        }
        return MacAdmittedDocumentExecution(
            source: document,
            colorSpace: colorSpace,
            background: background,
            logicalBounds: Self.rectangle(document.plane.logicalBounds),
            marks: marks
        )
    }
}
