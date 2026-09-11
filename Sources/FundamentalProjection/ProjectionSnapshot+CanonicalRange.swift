import Foundation

extension ProjectionSnapshot
{
    static func range(
        _ lowerBound: Int,
        _ upperBound: Int
    ) -> ProjectedUTF16Range
    {
        ProjectedUTF16Range(lowerBound..<upperBound)
    }

}
