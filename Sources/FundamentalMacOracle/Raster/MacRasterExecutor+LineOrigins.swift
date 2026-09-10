import FundamentalPresentation

extension MacRasterExecutor
{
    static func lineOrigins(
        _ residents: PresentedResidentCollection
    ) -> [PresentationResidentID: MacRasterLineOrigin]
    {
        var seen: Set<PresentationResidentID> = []
        var origins: [PresentationResidentID: MacRasterLineOrigin] = [:]
        for resident in residents.all
        {
            guard seen.insert(resident.residentID).inserted
            else
            {
                origins.removeValue(forKey: resident.residentID)
                continue
            }
            origins[resident.residentID] = MacRasterLineOrigin(resident)
        }
        return origins
    }
}
