import UIKit

public final class RoomBadge: UIView {

    public enum Variant {
        case danger
        case info
        case success
    }

    public var value: String = "" {
        didSet {
            guard oldValue != value else { return }
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    public var max: Int = 99 {
        didSet {
            guard oldValue != max else { return }
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    public var isDot: Bool = false {
        didSet {
            guard oldValue != isDot else { return }
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    public var isBadgeHidden: Bool = false {
        didSet {
            guard oldValue != isBadgeHidden else { return }
            setNeedsDisplay()
        }
    }

    public var variant: Variant = .danger {
        didSet {
            guard oldValue != variant else { return }
            setNeedsDisplay()
        }
    }

    private weak var hostView: UIView?
    private var badgeConstraints: [NSLayoutConstraint] = []
    private var unsubscribe: (() -> Void)?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setHost(_ view: UIView?) {
        hostView?.removeFromSuperview()
        hostView = view
        if let view {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        setNeedsDisplay()
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            unsubscribe = ThemeStore.shared.subscribe { [weak self] _ in
                self?.setNeedsDisplay()
            }
        } else {
            unsubscribe?()
            unsubscribe = nil
        }
    }

    override public var intrinsicContentSize: CGSize {
        if hostView != nil {
            return hostView?.intrinsicContentSize ?? .zero
        }
        return standaloneBadgeSize()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override public func draw(_ rect: CGRect) {
        if isBadgeHidden { return }
        let theme = ThemeStore.shared.theme
        let display = displayText()
        let isDotShape = isDot || variant == .success || display.isEmpty

        let badgeSize = standaloneBadgeSize()
        let badgeRect: CGRect
        if hostView != nil {
            let origin = CGPoint(x: rect.width - badgeSize.width / 2, y: 0)
            badgeRect = CGRect(origin: origin, size: badgeSize)
        } else {
            badgeRect = CGRect(
                x: (rect.width - badgeSize.width) / 2,
                y: (rect.height - badgeSize.height) / 2,
                width: badgeSize.width,
                height: badgeSize.height
            )
        }

        if variant == .success {
            theme.successFg.setFill()
            UIBezierPath(
                roundedRect: badgeRect.insetBy(dx: -1.5, dy: -1.5),
                cornerRadius: badgeRect.height / 2 + 1.5
            ).fill()
            ColorMix.withAlpha(theme.successFg, 0.35).setFill()
            UIBezierPath(
                roundedRect: badgeRect.insetBy(dx: -4, dy: -4),
                cornerRadius: badgeRect.height / 2 + 4
            ).fill()
            theme.successFg.setFill()
            UIBezierPath(roundedRect: badgeRect, cornerRadius: badgeRect.height / 2).fill()
            return
        }

        if variant == .info {
            theme.accentSoft.setFill()
        } else {
            theme.danger.setFill()
        }
        UIBezierPath(roundedRect: badgeRect, cornerRadius: badgeRect.height / 2).fill()

        if isDotShape {
            if hostView != nil {
                theme.bgSurface.setStroke()
                let path = UIBezierPath(roundedRect: badgeRect.insetBy(dx: -1, dy: -1), cornerRadius: badgeRect.height / 2 + 1)
                path.lineWidth = 2
                path.stroke()
            }
            return
        }

        let foreground = variant == .info
            ? (theme.mode == .light ? theme.accent : theme.accentHover)
            : theme.fgOnDanger
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
            .foregroundColor: foreground,
        ]
        let textSize = (display as NSString).size(withAttributes: attributes)
        (display as NSString).draw(
            at: CGPoint(
                x: badgeRect.minX + (badgeRect.width - textSize.width) / 2,
                y: badgeRect.minY + (badgeRect.height - textSize.height) / 2
            ),
            withAttributes: attributes
        )
    }

    private func displayText() -> String {
        if isDot || variant == .success { return "" }
        guard !value.isEmpty else { return "" }
        guard let number = Int(value) else { return value }
        return number > max ? "\(max)+" : value
    }

    private func standaloneBadgeSize() -> CGSize {
        let display = displayText()
        if isDot || variant == .success || display.isEmpty {
            return CGSize(width: 8, height: 8)
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
        ]
        let textWidth = (display as NSString).size(withAttributes: attributes).width
        return CGSize(width: Swift.max(16, textWidth + 4 * 2), height: 16)
    }
}
