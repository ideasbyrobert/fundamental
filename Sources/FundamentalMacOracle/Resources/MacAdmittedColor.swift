import CoreGraphics
import Foundation
import FundamentalPresentation

@MainActor
package struct MacAdmittedColor
{
    package let graphics: CGColor

    package init?(
        _ color: PresentationColor,
        colorSpace: MacAdmittedColorSpace
    )
    {
        let nativeComponents = (color.components + [color.alpha]).map
        {
            CGFloat($0)
        }
        guard let profile = colorSpace.graphics.copyICCData() as Data?,
              let name = colorSpace.native.localizedName,
              let admitted = PresentationColorSpaceIdentity(
            name: name,
            profile: Array(profile),
            componentCount: colorSpace.graphics.numberOfComponents
        ),
              admitted == color.colorSpace,
              let graphics = CGColor(
                  colorSpace: colorSpace.graphics,
                  components: nativeComponents
              ),
              graphics.components?.map(Double.init)
                == color.components + [color.alpha]
        else
        {
            return nil
        }
        self.graphics = graphics
    }
}
