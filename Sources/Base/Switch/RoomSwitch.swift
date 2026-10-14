import UIKit

public final class RoomSwitch: UIControl {

    public enum Size {
        case sm
        case md
        case lg

        var trackWidthPt: CGFloat {
            switch self {
            case .sm: return 24
            case .md: return 32
            case .lg: return 40
            }
        }

        var trackHeightPt: CGFloat {
            switch self {
            case .sm: return 14
            case .md: return 18
            case .lg: return 22
            }
        }
    }

    public var isChecked: Bool = false {
        didSet {
            guard oldValue != isChecked else { return }
            animateProgress(to: isChecked ? 1 : 0)
        }
    }

    public var size: Size = .md {
        didSet {
            guard oldValue != size else { return }
            invalidateIntrinsicContentSize()
        }
    }

    public var onCheckedChanged: ((Bool) -> Void)?

    private var progress: CGFloat = 0
    private var displayLink: CADisplayLink?
    private var animationStart: CFTimeInterval?
    private var progressFrom: CGFloat = 0
    private var progressTo: CGFloat = 0
    private var unsubscribe: (() -> Void)?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentMode = .redraw
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            alpha = isEnabled ? 1 : ThemeStore.shared.theme.disabledOpacity
        }
    }

    override public var intrinsicContentSize: CGSize {
        CGSize(width: size.trackWidthPt, height: size.trackHeightPt)
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            progress = isChecked ? 1 : 0
            unsubscribe = ThemeStore.shared.subscribe { [weak self] _ in
                self?.setNeedsDisplay()
            }
        } else {
            unsubscribe?()
            unsubscribe = nil
            stopAnimation()
        }
    }

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), rect.width > 0, rect.height > 0 else { return }
        let theme = ThemeStore.shared.theme
        let radius = rect.height / 2

        let offColor = theme.mode == .light ? UIColor(hex: 0xE5E5EA) : UIColor(hex: 0x9A9AA0)
        ColorMix.blend(theme.accent, offColor, progress).setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: radius).fill()

        let padding: CGFloat = 1
        let knobRadius = (rect.height - padding * 2) / 2
        let cx = padding + knobRadius + progress * (rect.width - padding * 2 - knobRadius * 2)
        let cy = rect.height / 2
        context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: 1), blur: 2, color: UIColor.black.withAlphaComponent(0.25).cgColor)
        RoomPalette.white.setFill()
        UIBezierPath(arcCenter: CGPoint(x: cx, y: cy), radius: knobRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true).fill()
        context.restoreGState()
    }

    @objc private func handleTap() {
        guard isEnabled else { return }
        let newValue = !isChecked
        isChecked = newValue
        onCheckedChanged?(newValue)
    }

    private func animateProgress(to target: CGFloat) {
        if window == nil {
            progress = target
            setNeedsDisplay()
            return
        }
        progressFrom = progress
        progressTo = target
        animationStart = nil
        if displayLink == nil {
            let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
            link.add(to: .main, forMode: .common)
            displayLink = link
        }
    }

    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        animationStart = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        if animationStart == nil {
            animationStart = link.timestamp
        }
        guard let start = animationStart else { return }
        let raw = CGFloat(min(max((link.targetTimestamp - start) / 0.18, 0), 1))
        let eased = 0.5 - 0.5 * cos(.pi * raw)
        progress = progressFrom + (progressTo - progressFrom) * eased
        setNeedsDisplay()
        if raw >= 1 {
            progress = progressTo
            stopAnimation()
        }
    }
}
