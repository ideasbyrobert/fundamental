import CoreFoundation
import Foundation

struct DocumentRecordUnsignedInteger
{
    static func decode(_ value: Any, path: [String]) throws -> UInt64
    {
        guard let number = value as? NSNumber,
              CFGetTypeID(number) != CFBooleanGetTypeID(),
              !["f", "d"].contains(String(cString: number.objCType)),
              let integer = value as? UInt64
        else
        {
            throw SemanticTableRecordCodec.invalid(
                path,
                "Expected an exact unsigned integer"
            )
        }
        return integer
    }
}
