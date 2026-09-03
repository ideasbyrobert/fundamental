import AppKit
import FundamentalPresentation

@MainActor
package struct MacDisplayIdentity
{
    package let colorSpace: MacAdmittedColorSpace
    package let presentation: PresentationColorSpaceIdentity
    package let backingScale: Double

    package init?(_ screen: NSScreen)
    {
        guard let native = screen.colorSpace,
              let graphics = native.cgColorSpace,
              let profile = graphics.copyICCData() as Data?,
              !profile.isEmpty,
              let name = native.localizedName,
              let identity = PresentationColorSpaceIdentity(
                  name: name,
                  profile: Array(profile),
                  componentCount: graphics.numberOfComponents
              ),
              let admitted = MacAdmittedColorSpace(identity),
              screen.backingScaleFactor.isFinite,
              screen.backingScaleFactor > 0
        else
        {
            return nil
        }
        colorSpace = admitted
        presentation = identity
        backingScale = screen.backingScaleFactor
    }
}
