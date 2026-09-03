import FundamentalViewport

extension ViewportRasterizer
{
    static func append(
        _ resident: ResidentLayoutFragment,
        targetBounds: RasterRectangle,
        specification: RasterSpecificationIdentity,
        ruleOwners: inout [RasterResidentID: RasterResidentID],
        accumulator: inout RasterAccumulator
    ) -> Bool
    {
        let anchor = resident.fragment.anchor
        let residentID = RasterResidentID(
            blockID: anchor.blockID,
            blockOrdinal: anchor.blockOrdinal,
            fragmentOrdinal: anchor.fragmentOrdinal
        )
        let residence = Self.residence(resident.residence)
        guard let frame = Self.rectangle(
            x: resident.fragment.frame.minX,
            y: resident.fragment.frame.minY,
            width: resident.fragment.frame.size.width,
            height: resident.fragment.frame.size.height
        )
        else
        {
            return false
        }
        switch resident.fragment
        {
        case let .lines(fragment):
            return Self.append(
                fragment.line,
                residentID: residentID,
                residence: residence,
                role: Self.role(fragment.role),
                frame: frame,
                targetBounds: targetBounds,
                specification: specification,
                accumulator: &accumulator
            )
        case let .grid(fragment):
            switch fragment.content
            {
            case let .captionLine(line):
                return Self.append(
                    line,
                    residentID: residentID,
                    residence: residence,
                    role: .caption,
                    frame: frame,
                    targetBounds: targetBounds,
                    specification: specification,
                    accumulator: &accumulator
                )
            case let .cellLine(line):
                return Self.append(
                    line.line,
                    residentID: residentID,
                    residence: residence,
                    role: Self.role(line),
                    frame: frame,
                    targetBounds: targetBounds,
                    specification: specification,
                    accumulator: &accumulator
                )
            case .region, .columnTrack, .rowTrack, .cell, .rule:
                return Self.appendGrid(
                    resident,
                    residentID: residentID,
                    residence: residence,
                    frame: frame,
                    targetBounds: targetBounds,
                    specification: specification,
                    ruleOwners: &ruleOwners,
                    accumulator: &accumulator
                )
            }
        }
    }

    private static func residence(
        _ residence: ViewportResidence
    ) -> RasterResidence
    {
        switch residence
        {
        case .visible:
            .visible
        case .overscan(.preceding):
            .overscan(.preceding)
        case .overscan(.following):
            .overscan(.following)
        }
    }

    private static func role(_ role: ResidentLayoutLineRole)
        -> RasterInteractionRole
    {
        switch role
        {
        case .prose(.body):
            .body
        case .prose(.title):
            .title
        case .prose(.section(.one)):
            .section(.one)
        case .prose(.section(.two)):
            .section(.two)
        case .prose(.section(.three)):
            .section(.three)
        case .prose(.section(.four)):
            .section(.four)
        case .prose(.section(.five)):
            .section(.five)
        case .prose(.section(.six)):
            .section(.six)
        case .code:
            .code
        }
    }

    private static func role(_ line: ResidentLayoutGridLine)
        -> RasterInteractionRole
    {
        switch line.scope
        {
        case .header:
            .headerCell(row: line.sourceRow, cell: line.sourceCell)
        case .body:
            .bodyCell(row: line.sourceRow, cell: line.sourceCell)
        }
    }
}
