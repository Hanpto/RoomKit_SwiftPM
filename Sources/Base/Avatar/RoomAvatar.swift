import UIKit

public final class RoomAvatar: UIView {

    public var text: String? {
        didSet { setNeedsDisplay() }
    }

    public var image: UIImage? {
        didSet { setNeedsDisplay() }
    }

    public var url: String? {
        didSet {
            guard oldValue != url else { return }
            let target = url
            image = nil
            RoomImageLoader.load(url: target) { [weak self] loaded in
                guard let self, self.url == target else { return }
                self.image = loaded
            }
        }
    }

    private var unsubscribe: (() -> Void)?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentMode = .redraw
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var intrinsicContentSize: CGSize {
        CGSize(width: 32, height: 32)
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

    override public func draw(_ rect: CGRect) {
        guard rect.width > 0, rect.height > 0 else { return }
        let radius = rect.width / 2
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()

        if let image {
            let scale = max(rect.width / image.size.width, rect.height / image.size.height)
            let drawSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let origin = CGPoint(x: (rect.width - drawSize.width) / 2, y: (rect.height - drawSize.height) / 2)
            image.draw(in: CGRect(origin: origin, size: drawSize))
            return
        }

        let theme = ThemeStore.shared.theme
        theme.accent.setFill()
        UIRectFill(rect)

        let initial = initialText()
        guard !initial.isEmpty else { return }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: fontSize(side: min(rect.width, rect.height))),
            .foregroundColor: theme.fgOnAccent,
        ]
        let textSize = (initial as NSString).size(withAttributes: attributes)
        (initial as NSString).draw(
            at: CGPoint(x: (rect.width - textSize.width) / 2, y: (rect.height - textSize.height) / 2),
            withAttributes: attributes
        )
    }

    private func fontSize(side: CGFloat) -> CGFloat {
        max(side * 0.4, 10)
    }

    private func initialText() -> String {
        guard let source = text?.trimmingCharacters(in: .whitespacesAndNewlines), !source.isEmpty else {
            return ""
        }
        guard let first = source.first else { return "" }
        if let scalar = first.unicodeScalars.first, scalar.value >= 0x4E00 && scalar.value <= 0x9FFF {
            return String(first)
        }
        if first.isLetter {
            return first.uppercased()
        }
        return String(first)
    }
}
