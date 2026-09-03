import FundamentalProjection

package struct LayoutGrid: Equatable, Sendable
{
    package let source: ProjectedBlockSource
    package let frame: LayoutRectangle
    package let structuralFont: LayoutFontIdentity
    package let columnTracks: [LayoutColumnTrack]
    package let rowTracks: [LayoutRowTrack]
    package let cells: [LayoutCell]
    package let captionLines: [LayoutLine]
    package let cellLines: [LayoutGridLine]
}
