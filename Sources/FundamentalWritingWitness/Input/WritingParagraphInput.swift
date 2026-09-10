import FundamentalDocument

struct WritingParagraphInput
{
    let paragraphs: [SemanticParagraph]

    init(_ runs: [SemanticRun], sourceLines: Bool)
    {
        if sourceLines
        {
            paragraphs = [SemanticParagraph(runs: runs)]
            return
        }
        var paragraphs: [SemanticParagraph] = []
        var current: [SemanticRun] = []
        var precedingCR = false
        for run in runs
        {
            if run.text.isEmpty
            {
                current.append(run)
                continue
            }
            var fragment = ""
            for scalar in run.text.unicodeScalars
            {
                if scalar.value == 0x0A && precedingCR
                {
                    precedingCR = false
                    continue
                }
                precedingCR = scalar.value == 0x0D
                if scalar.value == 0x0A || precedingCR
                {
                    if !fragment.isEmpty
                    {
                        current.append(SemanticRun(text: fragment,
                                                   attributes: run.attributes))
                        fragment = ""
                    }
                    paragraphs.append(SemanticParagraph(runs: current))
                    current = []
                }
                else
                {
                    fragment.unicodeScalars.append(scalar)
                }
            }
            if !fragment.isEmpty
            {
                current.append(SemanticRun(text: fragment,
                                           attributes: run.attributes))
            }
        }
        paragraphs.append(SemanticParagraph(runs: current))
        self.paragraphs = paragraphs
    }
}
