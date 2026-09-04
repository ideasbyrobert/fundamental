import FundamentalProjection

enum LayoutBlockMeasurementKind: Equatable, Sendable
{
    case prose(ProjectedProseRole)
    case code
    case table(LayoutTableMeasurement)
}
