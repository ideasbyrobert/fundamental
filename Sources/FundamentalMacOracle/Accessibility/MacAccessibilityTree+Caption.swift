import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func caption(
        for table: PresentedResident,
        residents: [PresentedResident],
        view: NSView,
        horizontalInset: Double,
        parent: MacAccessibilityElement
    ) -> MacAccessibilityElement?
    {
        let lines = residents.compactMap
        {
            resident -> (PresentedResident, String)? in
            guard resident.residentID.blockID
                    == table.residentID.blockID,
                  resident.residentID.blockOrdinal
                    == table.residentID.blockOrdinal,
                  case let .caption(line) = resident.content
            else
            {
                return nil
            }
            return (resident, line.text)
        }.sorted
        {
            $0.0.residentID.fragmentOrdinal
                < $1.0.residentID.fragmentOrdinal
        }
        guard let first = lines.first
        else
        {
            return nil
        }
        let frame = lines.dropFirst().reduce(screenFrame(
            first.0,
            view: view,
            horizontalInset: horizontalInset
        ))
        {
            result, line in
            result.union(screenFrame(
                line.0,
                view: view,
                horizontalInset: horizontalInset
            ))
        }
        return element(
            .caption(lines.map(\.1).joined()),
            frame: frame,
            parent: parent
        )
    }
}
