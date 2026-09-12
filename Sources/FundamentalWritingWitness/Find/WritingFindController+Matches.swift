import AppKit

extension WritingFindController
{
    func refresh()
    {
        guard !bar.isHidden, let owner
        else
        {
            return
        }
        let projection = owner.bridge.projection
        if let query = WritingFindQuery(bar.query.stringValue,
                                        caseSensitive: caseSensitive)
        {
            if results?.observation != projection.observation ||
                results?.query != query
            {
                results = WritingFindResults(query, in: projection)
            }
        }
        else
        {
            results = nil
        }
        let ranges = results?.ranges ?? []
        if let index = ranges.firstIndex(of: projection.selection)
        {
            bar.count.stringValue = "\(index + 1) of \(ranges.count)"
        }
        else
        {
            bar.count.stringValue = ranges.count == 1 ? "1 match" :
                "\(ranges.count) matches"
        }
        bar.next.isEnabled = !ranges.isEmpty
        bar.previous.isEnabled = !ranges.isEmpty
        bar.replace.isEnabled = ranges.contains(projection.selection)
        bar.replaceAll.isEnabled = !ranges.isEmpty
    }

    @objc func nextMatch(_ sender: Any?)
    {
        navigate(backwards: false)
    }

    @objc func previousMatch(_ sender: Any?)
    {
        navigate(backwards: true)
    }

    func navigate(backwards: Bool)
    {
        guard let owner,
              owner.bridge.finishComposition(in: owner.textView)
        else
        {
            return
        }
        refresh()
        guard let range = results?.next(
            from: owner.bridge.projection.selection, backwards: backwards
        ), let proposal = WritingSelectionProposal(
            ranges: [range], in: owner.bridge.projection
        )
        else
        {
            return
        }
        owner.fileOwner.session.submit(proposal.command)
        owner.bridge.project(in: owner.textView)
        owner.updateWritingGeometry()
    }
}
