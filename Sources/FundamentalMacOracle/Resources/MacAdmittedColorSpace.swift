import AppKit
import CoreGraphics
import FundamentalPresentation

@MainActor
package struct MacAdmittedColorSpace
{
    package let graphics: CGColorSpace
    package let native: NSColorSpace

    package init?(_ identity: PresentationColorSpaceIdentity)
    {
        let data = Data(identity.profile)
        guard let graphics = CGColorSpace(iccData: data as CFData),
              let copied = graphics.copyICCData() as Data?,
              copied == data,
              graphics.numberOfComponents == identity.componentCount,
              let native = NSColorSpace(cgColorSpace: graphics),
              native.localizedName == identity.name
        else
        {
            return nil
        }
        self.graphics = graphics
        self.native = native
    }
}
