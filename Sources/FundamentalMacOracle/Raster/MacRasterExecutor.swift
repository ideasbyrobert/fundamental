import CoreGraphics
import FundamentalPresentation

@MainActor
struct MacRasterExecutor
{
    func admit(
        _ snapshot: PresentationSnapshot
    ) -> MacAdmittedRasterExecution?
    {
        guard let document = admit(snapshot.presentedDocument)
        else
        {
            return nil
        }
        return admit(snapshot, document: document)
    }

    func admit(
        _ snapshot: PresentationSnapshot,
        reusing execution: MacAdmittedDocumentExecution
    ) -> MacAdmittedRasterExecution?
    {
        let document: MacAdmittedDocumentExecution
        if snapshot.presentedDocument.sharesStorage(
            with: execution.source
        )
        {
            document = execution
        }
        else
        {
            guard let admitted = admit(snapshot.presentedDocument)
            else
            {
                return nil
            }
            document = admitted
        }
        return admit(snapshot, document: document)
    }

    static func admitsTextMatrix(
        _ value: PresentationAffineTransform
    ) -> Bool
    {
        value.a == 1
            && value.b == 0
            && value.c == 0
            && value.d == 1
            && value.tx == 0
            && value.ty == 0
    }

    static func rectangle(
        _ value: PresentationRectangle
    ) -> CGRect
    {
        CGRect(
            x: value.origin.x,
            y: value.origin.y,
            width: value.size.width,
            height: value.size.height
        )
    }
}
