import CoreFoundation
import Foundation

extension SemanticTableRecordCodec
{
    static func rootObject(
        from data: Data
    ) throws -> [String: Any]
    {
        let value = try JSONSerialization.jsonObject(with: data)
        return try object(value, path: [])
    }

    static func requireKeys(
        _ object: [String: Any],
        _ expected: [String],
        path: [String]
    ) throws
    {
        guard Set(object.keys) == Set(expected)
        else
        {
            throw invalid(path, "Unexpected object members")
        }
    }

    static func required(
        _ key: String,
        in object: [String: Any],
        path: [String]
    ) throws -> Any
    {
        guard let value = object[key]
        else
        {
            throw invalid(path + [key], "Missing required member")
        }
        return value
    }

    static func object(
        _ value: Any,
        path: [String]
    ) throws -> [String: Any]
    {
        guard let object = value as? [String: Any]
        else
        {
            throw invalid(path, "Expected an object")
        }
        return object
    }

    static func array(
        _ value: Any,
        path: [String]
    ) throws -> [Any]
    {
        guard let array = value as? [Any]
        else
        {
            throw invalid(path, "Expected an array")
        }
        return array
    }

    static func string(
        _ value: Any,
        path: [String]
    ) throws -> String
    {
        guard let string = value as? String
        else
        {
            throw invalid(path, "Expected a string")
        }
        return string
    }

    static func integer(
        _ value: Any,
        path: [String]
    ) throws -> Int
    {
        guard let number = value as? NSNumber,
              !isBoolean(number),
              let integer = value as? Int
        else
        {
            throw invalid(path, "Expected an integer")
        }
        return integer
    }

    static func number(
        _ value: Any,
        path: [String]
    ) throws -> Double
    {
        guard let number = value as? NSNumber,
              !isBoolean(number)
        else
        {
            throw invalid(path, "Expected a number")
        }
        return number.doubleValue
    }

    static func key(
        _ value: String
    ) -> SemanticTableRecordCodingKey
    {
        SemanticTableRecordCodingKey(value)
    }

    static func invalid(
        _ path: [String],
        _ description: String
    ) -> DecodingError
    {
        DecodingError.dataCorrupted(.init(
            codingPath: path.map(SemanticTableRecordCodingKey.init),
            debugDescription: description
        ))
    }

    private static func isBoolean(_ number: NSNumber) -> Bool
    {
        CFGetTypeID(number) == CFBooleanGetTypeID()
    }
}
