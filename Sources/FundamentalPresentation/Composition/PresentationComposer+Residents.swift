import FundamentalRaster

extension PresentationComposer
{
    static func resident(
        _ value: RasterInteractionRegion,
        marks: [PresentationMark],
        reusable: [PresentationResidentID: PresentedResidentStorage]
    ) -> PresentedResident?
    {
        guard let identifier = residentID(value.residentID),
              let frame = rectangle(value.frame),
              let content = residentContent(
                  role: value.role,
                  content: value.content,
                  residentID: identifier
              ),
              marks.allSatisfy(
              {
                  $0.residentID == identifier
              }),
              validMarkSources(
                  marks,
                  residentID: identifier,
                  content: content
              )
        else
        {
            return nil
        }
        let candidate = PresentedResidentStorage(
            residentID: identifier,
            frame: frame,
            content: content,
            marks: marks
        )
        let storage: PresentedResidentStorage
        if let previous = reusable[identifier],
           previous == candidate
        {
            storage = previous
        }
        else
        {
            storage = candidate
        }
        return PresentedResident(
            residence: residence(value.residence),
            storage: storage
        )
    }
}
