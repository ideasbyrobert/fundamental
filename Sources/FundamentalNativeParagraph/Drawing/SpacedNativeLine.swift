import CoreText

@MainActor
package struct SpacedNativeLine
{
    package let plan: ParagraphPlannedLine
    package let runs: [SpacedNativeRun]
    package let advance: Double

    package init(_ plan: ParagraphPlannedLine) throws
    {
        let measured = try ParagraphLineMetrics(
            plan.shaped.measurement, units: plan.shaped.display.units
        )
        guard measured == plan.metrics
        else
        {
            throw NativeSpacingFailure.changedMetrics
        }
        let adjustments = try SpacingAdjustments(plan)
        let native: [CTRun]
        if let line = plan.shaped.measurement.native
        {
            native = CTLineGetGlyphRuns(line) as! [CTRun]
        }
        else
        {
            native = []
        }
        guard native.count == plan.shaped.runs.count
        else
        {
            throw NativeSpacingFailure.changedMetrics
        }
        var gaps: Set<Int> = []
        let runs = try native.indices.map
        {
            try SpacedNativeRun(
                native: native[$0], original: plan.shaped.runs[$0], plan: plan,
                adjustments: adjustments, gaps: &gaps
            )
        }
        guard gaps == Set(adjustments.indices)
        else
        {
            throw NativeSpacingFailure.ambiguousGap
        }
        let advance = runs.flatMap(\.glyphs).map
        {
            $0.position.x + $0.advance.width
        }.max() ?? 0
        guard abs(advance - plan.spacing.advance) < 0.000001
        else
        {
            throw NativeSpacingFailure.invalidPlan
        }
        self.plan = plan
        self.runs = runs
        self.advance = advance
    }

    package func draw(in context: CGContext, origin: CGPoint, ink: CGColor)
    {
        let matrix = context.textMatrix
        let position = context.textPosition
        context.saveGState()
        context.textMatrix = .identity
        context.textPosition = .zero
        context.setTextDrawingMode(.fill)
        context.setFillColor(ink)
        for run in runs
        {
            let glyphs = run.glyphs.map(\.original.identifier)
            let positions = run.glyphs.map
            {
                CGPoint(
                    x: origin.x + $0.position.x, y: origin.y + $0.position.y
                )
            }
            CTFontDrawGlyphs(run.font, glyphs, positions, glyphs.count, context)
            for decoration in run.decorations
            {
                context.fill(decoration.bounds.offsetBy(
                    dx: origin.x, dy: origin.y
                ))
            }
        }
        context.restoreGState()
        context.textMatrix = matrix
        context.textPosition = position
    }
}
