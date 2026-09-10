import FundamentalPresentation

extension MacReaderModel
{
    func publish(
        surface: SummitPresentationSurface,
        intent: FundamentalPresentation.PresentationIntent
    ) -> Bool
    {
        guard let lease = preparation.reserveAttempt(),
              let attempt = preparation.prepare(
                  surface: surface,
                  intent: intent,
                  lease: lease
              ),
              publish(attempt)
        else
        {
            return false
        }
        return true
    }

    @discardableResult
    func publish(_ attempt: SummitPresentationAttempt) -> Bool
    {
        guard let execution = executor.admit(
            attempt.snapshot,
            reusing: currentPublication.execution.documentExecution
        ),
              let publication = MacReaderPublication(
                  snapshot: attempt.snapshot,
                  execution: execution
              ),
              preparation.publish(attempt)
        else
        {
            return false
        }
        currentPublication = publication
        currentSurface = attempt.surface
        return true
    }
}
