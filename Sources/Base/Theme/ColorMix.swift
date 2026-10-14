import UIKit

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public enum ColorMix {

    public static func blend(_ colorA: UIColor, _ colorB: UIColor, _ weightA: CGFloat) -> UIColor {
        let weight = min(max(weightA, 0), 1)
        let a = rgba(colorA)
        let b = rgba(colorB)
        return UIColor(
            red: a.red * weight + b.red * (1 - weight),
            green: a.green * weight + b.green * (1 - weight),
            blue: a.blue * weight + b.blue * (1 - weight),
            alpha: a.alpha * weight + b.alpha * (1 - weight)
        )
    }

    public static func withAlpha(_ color: UIColor, _ alpha: CGFloat) -> UIColor {
        let components = rgba(color)
        return UIColor(
            red: components.red,
            green: components.green,
            blue: components.blue,
            alpha: min(max(alpha, 0), 1)
        )
    }

    public static func darken(_ color: UIColor, _ amount: CGFloat) -> UIColor {
        blend(color, RoomPalette.black, 1 - min(max(amount, 0), 1))
    }

    public static func luminance(_ color: UIColor) -> CGFloat {
        let components = rgba(color)
        return 0.299 * components.red + 0.587 * components.green + 0.114 * components.blue
    }

    public static func isLight(_ color: UIColor, threshold: CGFloat = 0.65) -> Bool {
        luminance(color) >= threshold
    }

    private static func rgba(_ color: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
