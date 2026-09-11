@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Foundation

extension MappedNativeRun
{
    var signature: [String: Any]
    {
        [
            "font": font.postScript, "size": font.pointSize,
            "glyphs": glyphs.map(\.identifier),
            "indices": glyphs.map(\.stringIndex),
            "positions": glyphs.map { [$0.position.x, $0.position.y] },
            "advances": glyphs.map { [$0.advance.width, $0.advance.height] }
        ]
    }
}
