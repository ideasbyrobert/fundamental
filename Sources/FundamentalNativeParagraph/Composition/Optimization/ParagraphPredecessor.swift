enum ParagraphPredecessor: Equatable
{
    case start
    case state(node: Int, fitness: ParagraphFitness)
}
