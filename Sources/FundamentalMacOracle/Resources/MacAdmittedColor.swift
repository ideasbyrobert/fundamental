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
        guard colorSpace.identity == color.colorSpace,
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
