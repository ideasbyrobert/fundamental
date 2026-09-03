import Testing
@testable import FundamentalLayout

@Suite("A layout request")
struct LayoutRequestTests
{
    @Test("requires one finite positive width and finite spacing")
    func admission()
    {
        let valid = LayoutRequest(
            generation: 9,
            width: 640,
            blockSpacing: 12,
            rowSpacing: 4,
            columnSpacing: 6,
            cellPadding: 8
        )
        #expect(valid?.generation == 9)
        #expect(valid?.parameters.width == 640)
        let widths: [Double] = [
            0,
            -1,
            .infinity,
            -.infinity,
            .nan
        ]
        for width in widths
        {
            #expect(LayoutRequest(
                generation: 0,
                width: width,
                blockSpacing: 0,
                rowSpacing: 0,
                columnSpacing: 0,
                cellPadding: 0
            ) == nil)
        }
        let spacings: [Double] = [
            -1,
            .infinity,
            -.infinity,
            .nan
        ]
        for spacing in spacings
        {
            #expect(request(blockSpacing: spacing) == nil)
            #expect(request(rowSpacing: spacing) == nil)
            #expect(request(columnSpacing: spacing) == nil)
            #expect(request(cellPadding: spacing) == nil)
        }
    }

    func request(
        blockSpacing: Double = 0,
        rowSpacing: Double = 0,
        columnSpacing: Double = 0,
        cellPadding: Double = 0
    ) -> LayoutRequest?
    {
        LayoutRequest(
            generation: 0,
            width: 1,
            blockSpacing: blockSpacing,
            rowSpacing: rowSpacing,
            columnSpacing: columnSpacing,
            cellPadding: cellPadding
        )
    }
}
