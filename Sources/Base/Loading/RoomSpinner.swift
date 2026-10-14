import UIKit

public final class RoomSpinner: UIView {

    public var color: UIColor = ThemeStore.shared.theme.accent {
        didSet { setNeedsDisplay() }
    }

    private var displayLink: CADisplayLink?
    private var startTimestamp: CFTimeInterval?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        contentMode = .redraw
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var isHidden: Bool {
        didSet {
            guard oldValue != isHidden else { return }
            isHidden ? stopAnimating() : startAnimating()
        }
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && !isHidden {
            startAnimating()
        } else {
            stopAnimating()
        }
    }

    public func startAnimating() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
        setNeedsDisplay()
    }

    public func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
        startTimestamp = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        if startTimestamp == nil {
            startTimestamp = link.timestamp
        }
        setNeedsDisplay()
    }

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let side = min(rect.width, rect.height)
        let stroke = side * 0.16
        let inset = stroke / 2 + 0.5
        let drawingRect = CGRect(
            x: rect.minX + (rect.width - side) / 2 + inset,
            y: rect.minY + (rect.height - side) / 2 + inset,
            width: side - inset * 2,
            height: side - inset * 2
        )
        guard drawingRect.width > 0, drawingRect.height > 0 else { return }

        let angle = currentAngle()
        let center = CGPoint(x: drawingRect.midX, y: drawingRect.midY)
        let radius = drawingRect.width / 2

        context.setLineWidth(stroke)
        context.setLineCap(.round)

        trackColor().setStroke()
        context.strokeEllipse(in: drawingRect)

        color.setStroke()
        let arc = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: angle * .pi / 180,
            endAngle: (angle + 90) * .pi / 180,
            clockwise: true
        )
        arc.lineWidth = stroke
        arc.lineCapStyle = .round
        arc.stroke()
    }

    private func trackColor() -> UIColor {
        ColorMix.withAlpha(color, 0.30)
    }

    private func currentAngle() -> CGFloat {
        guard let link = displayLink, let start = startTimestamp else { return 0 }
        let elapsed = link.targetTimestamp - start
        let cycle = elapsed.truncatingRemainder(dividingBy: 0.8) / 0.8
        return CGFloat(cycle) * 360
    }
}
