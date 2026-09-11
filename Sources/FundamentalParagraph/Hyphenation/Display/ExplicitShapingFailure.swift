package enum ExplicitShapingFailure: Error, Equatable, Sendable
{
    case displayLength
    case displayRange(Range<Int>)
    case nativeRange
    case nativeIndex
    case missingNativeIndices
    case nativeMeasurement
    case nonfiniteGeometry
    case missingFontIdentity
}
