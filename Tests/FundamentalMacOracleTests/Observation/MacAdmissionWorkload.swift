import FundamentalPresentation

struct MacAdmissionWorkload
{
    let snapshot: PresentationSnapshot
    let colors: [PresentationColor]
    let fonts: [(identity: PresentationFontIdentity, text: String)]

    init(_ snapshot: PresentationSnapshot)
    {
        self.snapshot = snapshot
        var colors = [snapshot.presentedDocument.plane.palette
            .documentBackground]
        var fonts: [(PresentationFontIdentity, String)] = []
        for mark in snapshot.presentedDocument.marks
        {
            switch mark
            {
            case let .fill(fill):
                colors.append(fill.color)
            case let .glyphs(batch):
                colors.append(batch.color)
                fonts.append((
                    batch.font,
                    batch.sourceSlices.map(\.text).joined()
                ))
            }
        }
        switch snapshot
        {
        case .document:
            break
        case let .caret(_, caret):
            colors.append(caret.color)
        case let .selection(_, selection):
            colors.append(selection.color)
        }
        self.colors = colors
        self.fonts = fonts
    }

    func report(_ label: String)
    {
        let document = snapshot.presentedDocument
        print(
            "WORKLOAD \(label) residents=\(document.residents.all.count)"
                + " marks=\(document.marks.count) glyphBatches=\(fonts.count)"
                + " colorAdmissions=\(colors.count)"
                + " iccBytes=\(document.plane.colorSpace.profile.count)"
        )
    }
}
