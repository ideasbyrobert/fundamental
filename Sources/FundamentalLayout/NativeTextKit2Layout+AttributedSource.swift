import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func attributedSource(
        runs: [ProjectedRun],
        font: NSFont
    ) throws -> (NSAttributedString, [NativeSourceSegment])
    {
        let attributed = NSMutableAttributedString(string: "")
        var segments: [NativeSourceSegment] = []
        var offset = 0
        for run in runs
        {
            let length = run.text.utf16.count
            attributed.append(NSAttributedString(
                string: run.text,
                attributes: try attributes(
                    font: font,
                    traits: run.traits
                )
            ))
            segments.append(NativeSourceSegment(
                source: run.source,
                scope: runScope(run),
                localRange: offset ..< offset + length,
                sourceLowerBound: sourceRange(run.source).lowerBound
            ))
            offset += length
        }
        return (attributed, segments)
    }

    func runScope(_ run: ProjectedRun) -> LayoutRunScope
    {
        switch run
        {
        case .direct:
            .direct
        case let .scoped(_, _, _, scope):
            switch scope
            {
            case let .link(destination):
                .link(destination)
            case let .language(identifier):
                .language(identifier)
            case let .linkAndLanguage(link, language):
                .linkAndLanguage(
                    link: link,
                    language: language
                )
            }
        }
    }
}
