import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func tableFont(_ scope: LayoutTableRowScope) throws -> NSFont
    {
        switch scope
        {
        case .header:
            try serifFont(ofSize: 15, weight: .semibold)
        case .body:
            try serifFont(ofSize: 15, weight: .regular)
        }
    }

}
