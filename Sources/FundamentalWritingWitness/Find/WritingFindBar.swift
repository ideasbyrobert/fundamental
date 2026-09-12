import AppKit

@MainActor
final class WritingFindBar: NSStackView
{
    let query = NSSearchField()
    let replacement = NSTextField()
    let count = NSTextField(labelWithString: "")
    let previous = NSButton()
    let next = NSButton()
    let done = NSButton(title: "Done", target: nil, action: nil)
    let replace = NSButton(title: "Replace", target: nil, action: nil)
    let replaceAll = NSButton(title: "Replace All", target: nil, action: nil)
    let replacementRow = NSStackView()
    let message = NSTextField(wrappingLabelWithString: "")

    var preferredHeight: CGFloat
    {
        44 + (replacementRow.isHidden ? 0 : 34) +
            (message.isHidden ? 0 : 40)
    }

    init()
    {
        super.init(frame: .zero)
        orientation = .vertical
        alignment = .leading
        spacing = 6
        edgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        configureControls()
        let searchRow = NSStackView(views: [query, count, previous, next, done])
        replacementRow.setViews([replacement, replace, replaceAll], in: .center)
        for row in [searchRow, replacementRow]
        {
            row.orientation = .horizontal
            row.spacing = 4
            row.alignment = .centerY
            addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: widthAnchor,
                                       constant: -16).isActive = true
        }
        addArrangedSubview(message)
        message.widthAnchor.constraint(equalTo: widthAnchor,
                                        constant: -16).isActive = true
        replacementRow.isHidden = true
        message.isHidden = true
        isHidden = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder)
    {
        return nil
    }
}
