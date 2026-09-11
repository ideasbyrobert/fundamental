extension WritingComposition
{
    var presentation: WritingProjection
    {
        input?.projection ?? baseline
    }
}
