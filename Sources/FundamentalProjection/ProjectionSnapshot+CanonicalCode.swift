import Foundation
import FundamentalDocument

extension ProjectionSnapshot
{
    static func project(
        _ code: SemanticCodeBlock,
        source: ProjectedBlockSource
    ) -> ProjectedBlock
    {
        let projected: ProjectedCode
        switch code
        {
        case let .plain(block):
            projected = .plain(
                projectBlockRuns(
                    block.runs,
                    blockID: source.blockID
                )
            )
        case let .languageTagged(block):
            projected = .languageTagged(
                language: block.language.value,
                runs: projectBlockRuns(
                    block.runs,
                    blockID: source.blockID
                )
            )
        }
        return .code(
            source: source,
            code: projected
        )
    }

}
