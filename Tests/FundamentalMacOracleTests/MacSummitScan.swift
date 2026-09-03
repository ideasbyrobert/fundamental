import AppKit
import FundamentalPresentation

@testable import FundamentalMacOracle

@MainActor
struct MacSummitScan
{
    let residents: [PresentedResident]

    init(
        width: Double = 820,
        height: Double = 680
    ) throws
    {
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        let model = try MacOracleTestSurface.model(
            width: width,
            height: height
        )
        let finalOrigin = max(0, model.documentHeight - height)
        let origins = Array(stride(
            from: 0.0,
            through: finalOrigin,
            by: 500
        )) + [finalOrigin]
        var observed: [PresentationResidentID: PresentedResident] = [:]
        for origin in origins
        {
            guard model.update(
                viewportWidth: width,
                viewportHeight: height,
                visibleOriginY: origin,
                screen: screen,
                appearance: appearance
            )
            else
            {
                throw MacOracleTestFailure.admission
            }
            for resident in model.snapshot.presentedDocument.residents.all
            {
                observed[resident.residentID] = resident
            }
        }
        residents = observed.values.sorted
        {
            lhs, rhs in
            if lhs.residentID.blockOrdinal
                == rhs.residentID.blockOrdinal
            {
                return lhs.residentID.fragmentOrdinal
                    < rhs.residentID.fragmentOrdinal
            }
            return lhs.residentID.blockOrdinal
                < rhs.residentID.blockOrdinal
        }
    }
}
