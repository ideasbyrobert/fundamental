import Foundation

enum WritingRecoveryFailure: LocalizedError
{
    case invalidRecord
    case oversizedRecord
    case unsafeLocation
    case unavailableCheckpoint

    var errorDescription: String?
    {
        switch self
        {
        case .invalidRecord:
            "This recovery checkpoint cannot be read. It has been retained."
        case .oversizedRecord:
            "This recovery checkpoint exceeds the supported document size."
        case .unsafeLocation:
            "The recovery location must contain ordinary files and folders."
        case .unavailableCheckpoint:
            "Recovery cannot checkpoint this session. Save your document."
        }
    }
}
