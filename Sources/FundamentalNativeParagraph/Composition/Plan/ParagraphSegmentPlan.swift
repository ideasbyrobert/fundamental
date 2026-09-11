@MainActor
package struct ParagraphSegmentPlan
{
    package let candidates: ParagraphBreakSet
    package let path: ParagraphPath
    package let lines: [ParagraphPlannedLine]
    package let nativeMeasurements: Int
    package let metricRequests: Int
}
