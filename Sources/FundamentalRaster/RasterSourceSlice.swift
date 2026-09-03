package struct RasterSourceSlice: Equatable, Sendable
{
    package let source: RasterTextSource
    package let scope: RasterRunScope
    package let range: Range<Int>
    package let text: String
}
