package enum DocumentRecordFailure: Error, Equatable
{
    case byteLimitExceeded
    case blockLimitExceeded
    case unsupportedFormat
    case unsupportedVersion(UInt64)
    case invalidContent
}
