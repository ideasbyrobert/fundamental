import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func proseFont(_ role: ProjectedProseRole) throws -> NSFont
    {
        switch role
        {
        case .bulleted, .numbered:
            throw LayoutFailure.unsupportedProseRole
        case .body:
            try serifFont(ofSize: 17, weight: .regular)
        case .title:
            try serifFont(ofSize: 28, weight: .semibold)
        case let .section(level):
            try serifFont(
                ofSize: sectionFontSize(level),
                weight: .semibold
            )
        }
    }

}
