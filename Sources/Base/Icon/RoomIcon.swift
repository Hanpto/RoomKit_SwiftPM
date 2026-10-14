import UIKit

public final class RoomIcon: UIImageView {

    private var customTint: UIColor?
    private var unsubscribe: (() -> Void)?

    public override var image: UIImage? {
        didSet { applyTint() }
    }

    public func setImageTint(_ color: UIColor?) {
        customTint = color
        applyTint()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            unsubscribe = ThemeStore.shared.subscribe { [weak self] _ in
                self?.applyTint()
            }
        } else {
            unsubscribe?()
            unsubscribe = nil
        }
    }

    private func applyTint() {
        if let current = image, current.renderingMode != .alwaysTemplate {
            image = current.withRenderingMode(.alwaysTemplate)
        }
        tintColor = customTint ?? ThemeStore.shared.theme.fgIcon
    }
}
