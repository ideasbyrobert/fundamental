import FundamentalRaster

extension PresentationComposer
{
    static func residentContent(
        role: RasterInteractionRole, content: RasterInteractionContent,
        residentID: PresentationResidentID
    ) -> PresentedResidentContent?
    {
        if case let .text(value) = content,
           value.marker != nil, listItem(role) == nil
        {
            return nil
        }
        switch (role, content)
        {
        case let (.body, .text(value)):
            return textContent(value, domain: .block(residentID.blockID))
                .map(PresentedResidentContent.body)
        case let (.title, .text(value)):
            return textContent(value, domain: .block(residentID.blockID))
                .map(PresentedResidentContent.title)
        case let (.section(level), .text(value)):
            guard let level = headingLevel(level),
                  let line = textContent(
                      value,
                      domain: .block(residentID.blockID)
                  )
            else
            {
                return nil
            }
            return .section(level, line)
        case let (.code, .text(value)):
            return textContent(value, domain: .block(residentID.blockID))
                .map(PresentedResidentContent.code)
        case let (.bulleted, .text(value)),
             let (.numbered, .text(value)):
            return listContent(value, role: role, residentID: residentID)
        default:
            return gridContent(
                role: role, content: content, residentID: residentID
            )
        }
    }
}
