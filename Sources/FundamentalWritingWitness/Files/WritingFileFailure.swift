enum WritingFileFailure: Error, Equatable
{
    case busy
    case unsupportedDocument
    case invalidLocation
    case acknowledgementRefused
    case unavailableWindow
}
