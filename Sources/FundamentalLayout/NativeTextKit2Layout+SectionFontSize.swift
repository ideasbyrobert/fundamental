import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func sectionFontSize(_ level: ProjectedHeadingLevel) -> Double
    {
        switch level
        {
        case .one:
            24
        case .two:
            22
        case .three:
            20
        case .four:
            19
        case .five:
            18
        case .six:
            17
        }
    }

}
