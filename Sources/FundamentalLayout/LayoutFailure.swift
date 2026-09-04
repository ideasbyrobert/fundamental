package enum LayoutFailure: Error, Equatable, Sendable
{
    case missingNativeLine
    case missingResolvedFontIdentity
    case nonfiniteNativeGeometry
    case invalidNativeSourceRange
    case inconsistentNativeShaping(
        textKitWidth: Double,
        coreTextWidth: Double
    )
    case unrepresentableGridExtent
    case unrepresentableBlockMeasurement
}
