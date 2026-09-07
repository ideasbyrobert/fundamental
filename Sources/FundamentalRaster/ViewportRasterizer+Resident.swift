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
            guard let role = Self.role(fragment.role)
            else
            {
                return false
            }
            return Self.append(
                fragment.line,
                residentID: residentID,
                residence: residence,
                role: role,
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

}
