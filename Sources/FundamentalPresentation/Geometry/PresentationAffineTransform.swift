package struct PresentationAffineTransform: Equatable, Sendable
{
    package let a: Double
    package let b: Double
    package let c: Double
    package let d: Double
    package let tx: Double
    package let ty: Double

    package init?(
        a: Double,
        b: Double,
        c: Double,
        d: Double,
        tx: Double,
        ty: Double
    )
    {
        guard [a, b, c, d, tx, ty].allSatisfy(\.isFinite)
        else
        {
            return nil
        }
        self.a = a == 0 ? 0 : a
        self.b = b == 0 ? 0 : b
        self.c = c == 0 ? 0 : c
        self.d = d == 0 ? 0 : d
        self.tx = tx == 0 ? 0 : tx
        self.ty = ty == 0 ? 0 : ty
    }
}
