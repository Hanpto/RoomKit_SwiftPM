import UIKit

public final class RoomButton: UIControl {

    public enum Variant {
        case primary
        case secondary
        case ghost
        case danger
    }

    public enum Size {
        case md
        case sm
    }

    public var variant: Variant = .secondary {
        didSet {
            guard oldValue != variant else { return }
            applyStyle()
        }
    }

    public var size: Size = .md {
        didSet {
            guard oldValue != size else { return }
            applyStyle()
        }
    }

    public var text: String? {
        didSet {
            guard oldValue != text else { return }
            label.text = text
            label.isHidden = text?.isEmpty ?? true
            applyStyle()
        }
    }

    public var icon: UIImage? {
        didSet {
            guard oldValue != icon else { return }
            applyLead()
            applyStyle()
        }
    }

    public func setIconNamed(_ name: String) {
        icon = RoomKitResources.image(named: name)
    }

    public var isLoading: Bool = false {
        didSet {
            guard oldValue != isLoading else { return }
            applyLead()
            applyStyle()
            setEnabledProgrammatically(!isLoading && !isDisabledLogically)
            if isLoading {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }

    public override var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            if !suppressLogicalTracking {
                isDisabledLogically = !isEnabled
            }
            alpha = isEnabled ? 1 : ThemeStore.shared.theme.disabledOpacity
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else { return }
            applyBackground()
        }
    }

    private let iconView = RoomIcon()
    private let spinner = RoomSpinner()
    private let label = UILabel()
    private var unsubscribe: (() -> Void)?
    private var isDisabledLogically = false
    private var suppressLogicalTracking = false

    override public init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false

        label.textAlignment = .center
        label.numberOfLines = 1
        label.isHidden = true

        iconView.isHidden = true
        iconView.isUserInteractionEnabled = false

        spinner.isHidden = true
        spinner.isUserInteractionEnabled = false

        addSubview(iconView)
        addSubview(spinner)
        addSubview(label)

        applyLead()
        applyStyle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            unsubscribe = ThemeStore.shared.subscribe { [weak self] _ in
                self?.applyStyle()
            }
        } else {
            unsubscribe?()
            unsubscribe = nil
        }
    }

    public override var intrinsicContentSize: CGSize {
        let iconOnlyValue = icon != nil && (text?.isEmpty ?? true)
        let height = resolvedHeight(iconOnly: iconOnlyValue)
        if iconOnlyValue {
            return CGSize(width: RoomTokens.Size.buttonIconOnlyDP, height: height)
        }
        let padding = resolvedPadding(iconOnly: false)
        let labelWidth = currentLabelWidth()
        let leadWidth = currentLeadWidth()
        let gap = (leadWidth > 0 && labelWidth > 0) ? RoomTokens.Spacing.buttonGapDP : 0
        return CGSize(width: padding * 2 + leadWidth + gap + labelWidth, height: height)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let iconOnlyValue = icon != nil && (text?.isEmpty ?? true)
        let leadWidth = currentLeadWidth()
        let labelWidth = currentLabelWidth()
        let gap = (leadWidth > 0 && labelWidth > 0) ? RoomTokens.Spacing.buttonGapDP : 0
        let total = leadWidth + gap + labelWidth
        var x = (bounds.width - total) / 2

        if leadWidth > 0 {
            let leadFrame = CGRect(x: x, y: (bounds.height - leadWidth) / 2, width: leadWidth, height: leadWidth)
            if isLoading {
                spinner.frame = leadFrame
            } else {
                iconView.frame = leadFrame
            }
            x += leadWidth + gap
        }
        if labelWidth > 0 || !label.isHidden {
            let textSize = label.intrinsicContentSize
            label.frame = CGRect(
                x: x,
                y: (bounds.height - textSize.height) / 2,
                width: max(textSize.width, 0),
                height: textSize.height
            )
        }
    }

    private func applyLead() {
        spinner.isHidden = !isLoading
        iconView.isHidden = isLoading || icon == nil
        if !isLoading {
            iconView.image = icon
        }
    }

    private func applyStyle() {
        let theme = ThemeStore.shared.theme

        let labelSize = size == .sm
            ? RoomTokens.Font.buttonLabelSMSP
            : RoomTokens.Font.buttonLabelMDSP
        label.font = .systemFont(ofSize: labelSize, weight: .bold)

        let foreground = foregroundColor(theme, variant)
        label.textColor = foreground
        iconView.setImageTint(foreground)
        spinner.color = foreground

        applyBackground()
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    private func applyBackground() {
        let theme = ThemeStore.shared.theme
        let iconOnlyValue = icon != nil && (text?.isEmpty ?? true)
        layer.cornerRadius = RoomTokens.Radius.controlDP
        let needsStroke = strokeNeeded(variant, iconOnly: iconOnlyValue)
        layer.borderWidth = needsStroke ? 1 : 0
        layer.borderColor = theme.border.cgColor
        let base = baseBackgroundColor(theme, variant, iconOnly: iconOnlyValue)
        let pressed = pressedBackgroundColor(theme, variant, iconOnly: iconOnlyValue)
        backgroundColor = isHighlighted ? pressed : base
    }

    private func setEnabledProgrammatically(_ enabled: Bool) {
        guard isEnabled != enabled else { return }
        suppressLogicalTracking = true
        isEnabled = enabled
        suppressLogicalTracking = false
    }

    private func foregroundColor(_ theme: RoomTheme, _ variant: Variant) -> UIColor {
        switch variant {
        case .primary: return theme.fgOnAccent
        case .danger: return theme.fgOnDanger
        case .secondary, .ghost: return theme.fgPrimary
        }
    }

    private func baseBackgroundColor(_ theme: RoomTheme, _ variant: Variant, iconOnly: Bool) -> UIColor {
        if iconOnly {
            return theme.mode == .light ? theme.bgSurface : theme.bgSurfaceSecondary
        }
        switch variant {
        case .primary: return theme.accent
        case .danger: return theme.danger
        case .ghost: return theme.bgHover
        case .secondary: return theme.bgSurface
        }
    }

    private func pressedBackgroundColor(_ theme: RoomTheme, _ variant: Variant, iconOnly: Bool) -> UIColor {
        if iconOnly {
            return theme.bgHover
        }
        switch variant {
        case .primary: return theme.accentHover
        case .danger: return theme.dangerHover
        case .ghost: return theme.bgHoverStrong
        case .secondary: return ColorMix.blend(theme.bgSurface, theme.fgPrimary, 0.92)
        }
    }

    private func strokeNeeded(_ variant: Variant, iconOnly: Bool) -> Bool {
        switch variant {
        case .ghost: return false
        case .primary: return iconOnly
        case .danger: return iconOnly
        case .secondary: return true
        }
    }

    private func resolvedHeight(iconOnly: Bool) -> CGFloat {
        if iconOnly { return RoomTokens.Size.buttonIconOnlyDP }
        if size == .sm { return RoomTokens.Size.buttonSMHeightDP }
        if variant == .primary { return RoomTokens.Size.buttonMobilePrimaryHeightDP }
        return RoomTokens.Size.buttonMDHeightDP
    }

    private func resolvedPadding(iconOnly: Bool) -> CGFloat {
        if iconOnly { return 0 }
        if size == .sm { return RoomTokens.Size.buttonPaddingSMDDP }
        if variant == .primary { return RoomTokens.Size.buttonMobilePrimaryPaddingDP }
        return RoomTokens.Size.buttonPaddingMDDP
    }

    private func currentLeadWidth() -> CGFloat {
        let hasText = !(text?.isEmpty ?? true)
        if isLoading {
            return hasText || icon != nil ? 14 : 0
        }
        guard icon != nil else { return 0 }
        let iconOnlyValue = !hasText
        if iconOnlyValue || size == .sm {
            return RoomTokens.Size.buttonIconSMDDP
        }
        return RoomTokens.Size.buttonIconMDDP
    }

    private func currentLabelWidth() -> CGFloat {
        guard let text, !text.isEmpty else { return 0 }
        return (text as NSString).size(withAttributes: [.font: label.font ?? .boldSystemFont(ofSize: 13)]).width
    }
}
