import UIKit

public struct RoomTheme {
    public enum Mode {
        case light
        case dark
    }

    public let mode: Mode
    public let accent: UIColor
    public let bgCanvas: UIColor
    public let bgSurface: UIColor
    public let bgSurfaceSecondary: UIColor
    public let bgInset: UIColor
    public let bgRaised: UIColor
    public let bgAvatar: UIColor
    public let bgCamera: UIColor
    public let bgInverse: UIColor
    public let bgGlass: UIColor
    public let bgOverlay: UIColor
    public let bgPopover: UIColor
    public let bgPopoverSolid: UIColor
    public let fgPrimary: UIColor
    public let fgSecondary: UIColor
    public let fgTertiary: UIColor
    public let fgIcon: UIColor
    public let fgAvatar: UIColor
    public let danger: UIColor
    public let fgOnDanger: UIColor
    public let warning: UIColor
    public let success: UIColor
    public let icoSlash: UIColor
    public let toggleOffHover: UIColor
    public let lockFill: UIColor
    public let lockBorder: UIColor
    public let lockChip: UIColor
    public let lockBadgeBg: UIColor
    public let lockBadgeBorder: UIColor
    public let lockTitle: UIColor
    public let lockSub: UIColor

    public var fgOnAccent: UIColor {
        ColorMix.isLight(accent) ? UIColor(hex: 0x1C1B1C) : RoomPalette.white
    }

    public var bgHover: UIColor { ColorMix.withAlpha(fgPrimary, 0.06) }
    public var bgHoverStrong: UIColor { ColorMix.withAlpha(fgPrimary, 0.10) }
    public var bgPress: UIColor { ColorMix.withAlpha(fgPrimary, 0.12) }

    public var border: UIColor {
        switch mode {
        case .light: return ColorMix.withAlpha(fgPrimary, 0.09)
        case .dark: return ColorMix.withAlpha(fgPrimary, 0.12)
        }
    }

    public var borderSubtle: UIColor {
        switch mode {
        case .light: return ColorMix.withAlpha(fgPrimary, 0.06)
        case .dark: return ColorMix.withAlpha(fgPrimary, 0.08)
        }
    }

    public var borderStrong: UIColor {
        switch mode {
        case .light: return ColorMix.withAlpha(fgPrimary, 0.14)
        case .dark: return ColorMix.withAlpha(fgPrimary, 0.18)
        }
    }

    public var accentHover: UIColor { ColorMix.darken(accent, 0.06) }
    public var accentSoft: UIColor { ColorMix.withAlpha(accent, 0.14) }
    public var accentSoftStrong: UIColor { ColorMix.withAlpha(accent, 0.22) }
    public var accentBorder: UIColor { ColorMix.withAlpha(accent, 0.28) }
    public var accentFill: UIColor { ColorMix.withAlpha(accent, 0.90) }
    public var dangerHover: UIColor { ColorMix.darken(danger, 0.06) }
    public var dangerSoft: UIColor { ColorMix.withAlpha(danger, 0.14) }
    public var dangerSoftStrong: UIColor { ColorMix.withAlpha(danger, 0.22) }

    public var dangerStrong: UIColor { RoomPalette.red400 }
    public var successFg: UIColor { RoomPalette.green200 }

    public var roleAuth: UIColor { RoomPalette.purple400 }
    public var roleAuthSoft: UIColor { ColorMix.withAlpha(roleAuth, 0.18) }
    public var roleOwnerSoft: UIColor { ColorMix.blend(accent, bgSurface, 0.20) }
    public var roleOwnerSoftFg: UIColor {
        switch mode {
        case .light: return ColorMix.blend(accent, RoomPalette.black, 0.78)
        case .dark: return ColorMix.blend(accent, RoomPalette.white, 0.70)
        }
    }
    public var roleAdminSoft: UIColor { ColorMix.blend(warning, bgSurface, 0.20) }
    public var roleAdminSoftFg: UIColor {
        switch mode {
        case .light: return ColorMix.blend(warning, RoomPalette.black, 0.58)
        case .dark: return warning
        }
    }

    public var tileChipBg: UIColor { UIColor(red: 112 / 255, green: 112 / 255, blue: 116 / 255, alpha: 0.62) }
    public var tileChipBgHover: UIColor { UIColor(red: 132 / 255, green: 132 / 255, blue: 136 / 255, alpha: 0.78) }
    public var borderSpeaking: UIColor { success }
    public var bgOnMedia: UIColor { UIColor(red: 0, green: 0, blue: 0, alpha: 0x73 / 255) }
    public var bgPageIndicator: UIColor { UIColor(red: 0, green: 0, blue: 0, alpha: 0x6B / 255) }
    public var fgOnMedia: UIColor { UIColor(red: 1, green: 1, blue: 1, alpha: 1) }

    public var focusRing: UIColor { ColorMix.withAlpha(accent, 0.55) }
    public var focusRingDanger: UIColor { ColorMix.withAlpha(danger, 0.55) }

    public var shadowColorMd: UIColor {
        switch mode {
        case .light: return UIColor(white: 0, alpha: 0.08)
        case .dark: return UIColor(white: 0, alpha: 0.40)
        }
    }
    public var shadowColorLg: UIColor {
        switch mode {
        case .light: return UIColor(white: 0, alpha: 0.12)
        case .dark: return UIColor(white: 0, alpha: 0.55)
        }
    }

    public var disabledOpacity: CGFloat { 0.45 }

    init(
        mode: Mode,
        accent: UIColor,
        bgCanvas: UIColor,
        bgSurface: UIColor,
        bgSurfaceSecondary: UIColor,
        bgInset: UIColor,
        bgRaised: UIColor,
        bgAvatar: UIColor,
        bgCamera: UIColor,
        bgInverse: UIColor,
        bgGlass: UIColor,
        bgOverlay: UIColor,
        bgPopover: UIColor,
        bgPopoverSolid: UIColor,
        fgPrimary: UIColor,
        fgSecondary: UIColor,
        fgTertiary: UIColor,
        fgIcon: UIColor,
        fgAvatar: UIColor,
        danger: UIColor,
        fgOnDanger: UIColor,
        warning: UIColor,
        success: UIColor,
        icoSlash: UIColor,
        toggleOffHover: UIColor,
        lockFill: UIColor,
        lockBorder: UIColor,
        lockChip: UIColor,
        lockBadgeBg: UIColor,
        lockBadgeBorder: UIColor,
        lockTitle: UIColor,
        lockSub: UIColor
    ) {
        self.mode = mode
        self.accent = accent
        self.bgCanvas = bgCanvas
        self.bgSurface = bgSurface
        self.bgSurfaceSecondary = bgSurfaceSecondary
        self.bgInset = bgInset
        self.bgRaised = bgRaised
        self.bgAvatar = bgAvatar
        self.bgCamera = bgCamera
        self.bgInverse = bgInverse
        self.bgGlass = bgGlass
        self.bgOverlay = bgOverlay
        self.bgPopover = bgPopover
        self.bgPopoverSolid = bgPopoverSolid
        self.fgPrimary = fgPrimary
        self.fgSecondary = fgSecondary
        self.fgTertiary = fgTertiary
        self.fgIcon = fgIcon
        self.fgAvatar = fgAvatar
        self.danger = danger
        self.fgOnDanger = fgOnDanger
        self.warning = warning
        self.success = success
        self.icoSlash = icoSlash
        self.toggleOffHover = toggleOffHover
        self.lockFill = lockFill
        self.lockBorder = lockBorder
        self.lockChip = lockChip
        self.lockBadgeBg = lockBadgeBg
        self.lockBadgeBorder = lockBadgeBorder
        self.lockTitle = lockTitle
        self.lockSub = lockSub
    }

    public static func light(accent: UIColor = RoomAccent.defaultAccent) -> RoomTheme {
        RoomTheme(
            mode: .light,
            accent: accent,
            bgCanvas: UIColor(hex: 0xF5F4F5),
            bgSurface: UIColor(hex: 0xFFFFFF),
            bgSurfaceSecondary: UIColor(hex: 0xEFEEEF),
            bgInset: UIColor(hex: 0xF2F1F2),
            bgRaised: UIColor(hex: 0xFFFFFF),
            bgAvatar: UIColor(hex: 0xB4B3B4),
            bgCamera: UIColor(hex: 0xE8E7E8),
            bgInverse: UIColor(hex: 0x1C1B1C),
            bgGlass: UIColor(white: 1, alpha: 0.82),
            bgOverlay: ColorMix.withAlpha(UIColor(hex: 0x141314), 0.32),
            bgPopover: UIColor(white: 1, alpha: 0.98),
            bgPopoverSolid: UIColor(white: 1, alpha: 0.99),
            fgPrimary: UIColor(hex: 0x1C1B1C),
            fgSecondary: UIColor(hex: 0x636263),
            fgTertiary: UIColor(hex: 0x8E8D8E),
            fgIcon: UIColor(hex: 0x3A393A),
            fgAvatar: UIColor(hex: 0xFFFFFF),
            danger: RoomPalette.red500,
            fgOnDanger: RoomPalette.white,
            warning: RoomPalette.orange500,
            success: RoomPalette.green400,
            icoSlash: UIColor(hex: 0xE0362B),
            toggleOffHover: UIColor(hex: 0xD8D8DC),
            lockFill: UIColor(red: 118 / 255, green: 124 / 255, blue: 134 / 255, alpha: 0.08),
            lockBorder: UIColor(red: 118 / 255, green: 124 / 255, blue: 134 / 255, alpha: 0.42),
            lockChip: UIColor(red: 118 / 255, green: 124 / 255, blue: 134 / 255, alpha: 0.14),
            lockBadgeBg: UIColor(red: 118 / 255, green: 124 / 255, blue: 134 / 255, alpha: 0.18),
            lockBadgeBorder: UIColor(red: 118 / 255, green: 124 / 255, blue: 134 / 255, alpha: 0.30),
            lockTitle: UIColor(hex: 0x72777F),
            lockSub: UIColor(hex: 0x979CA4)
        )
    }

    public static func dark(accent: UIColor = RoomAccent.defaultAccent) -> RoomTheme {
        RoomTheme(
            mode: .dark,
            accent: accent,
            bgCanvas: UIColor(hex: 0x0A0A0A),
            bgSurface: UIColor(hex: 0x1C1C1C),
            bgSurfaceSecondary: UIColor(hex: 0x2A2A2A),
            bgInset: UIColor(hex: 0x050505),
            bgRaised: UIColor(hex: 0x333333),
            bgAvatar: UIColor(hex: 0x3A3A3A),
            bgCamera: UIColor(hex: 0x161616),
            bgInverse: UIColor(hex: 0x000000),
            bgGlass: UIColor(white: 28.0 / 255, alpha: 0.92),
            bgOverlay: ColorMix.withAlpha(UIColor(hex: 0x000000), 0.58),
            bgPopover: UIColor(white: 28.0 / 255, alpha: 0.97),
            bgPopoverSolid: UIColor(white: 28.0 / 255, alpha: 0.99),
            fgPrimary: UIColor(hex: 0xF2F2F2),
            fgSecondary: UIColor(hex: 0x9A9A9A),
            fgTertiary: UIColor(hex: 0x6E6E6E),
            fgIcon: UIColor(hex: 0xC6C6C6),
            fgAvatar: UIColor(hex: 0xF2F2F2),
            danger: RoomPalette.red500,
            fgOnDanger: RoomPalette.white,
            warning: RoomPalette.orange500,
            success: RoomPalette.green400,
            icoSlash: RoomPalette.red500,
            toggleOffHover: UIColor(hex: 0x9A9AA0),
            lockFill: UIColor(red: 160 / 255, green: 166 / 255, blue: 176 / 255, alpha: 0.10),
            lockBorder: UIColor(red: 160 / 255, green: 166 / 255, blue: 176 / 255, alpha: 0.40),
            lockChip: UIColor(red: 160 / 255, green: 166 / 255, blue: 176 / 255, alpha: 0.16),
            lockBadgeBg: UIColor(red: 160 / 255, green: 166 / 255, blue: 176 / 255, alpha: 0.20),
            lockBadgeBorder: UIColor(red: 160 / 255, green: 166 / 255, blue: 176 / 255, alpha: 0.30),
            lockTitle: UIColor(hex: 0xA8ADB5),
            lockSub: UIColor(hex: 0x848A93)
        )
    }

    public static func of(_ mode: Mode, accent: UIColor = RoomAccent.defaultAccent) -> RoomTheme {
        switch mode {
        case .light: return light(accent: accent)
        case .dark: return dark(accent: accent)
        }
    }
}
