import UIKit

public enum RoomToast {

    public static let defaultDuration: TimeInterval = 2
    private static let fadeDuration: TimeInterval = 0.2
    private static var current: ToastLayer?
    private static var dismissWorkItem: DispatchWorkItem?

    public static func show(
        _ text: String,
        duration: TimeInterval = defaultDuration,
        icon: UIImage? = nil
    ) {
        guard let window = keyWindow() else { return }
        dismissCurrent()

        let layerView = ToastLayer(text: text, icon: icon)
        current = layerView
        layerView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(layerView)
        NSLayoutConstraint.activate([
            layerView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            layerView.leadingAnchor.constraint(greaterThanOrEqualTo: window.leadingAnchor, constant: 24),
            layerView.trailingAnchor.constraint(lessThanOrEqualTo: window.trailingAnchor, constant: -24),
            layerView.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),
        ])

        layerView.alpha = 0
        UIView.animate(withDuration: fadeDuration) {
            layerView.alpha = 1
        }

        let workItem = DispatchWorkItem {
            guard Self.current === layerView else { return }
            UIView.animate(
                withDuration: Self.fadeDuration,
                animations: { layerView.alpha = 0 },
                completion: { _ in
                    layerView.removeFromSuperview()
                    if Self.current === layerView {
                        Self.current = nil
                    }
                }
            )
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    public static func dismiss() {
        dismissCurrent()
    }

    private static func dismissCurrent() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil
        guard let layerView = current else { return }
        layerView.removeFromSuperview()
        current = nil
    }

    private static func keyWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let windows = scenes.flatMap { $0.windows }
        return windows.first { $0.isKeyWindow } ?? windows.first
    }
}

private final class ToastLayer: UIView {

    init(text: String, icon: UIImage?) {
        super.init(frame: .zero)

        let theme = ThemeStore.shared.theme
        let background = theme.bgInverse
        let foreground = theme.mode == .dark ? theme.fgPrimary : RoomPalette.white
        backgroundColor = background

        let label = UILabel()
        label.text = text
        label.textColor = foreground
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 1

        if let icon {
            let iconView = RoomIcon()
            iconView.image = icon
            iconView.setImageTint(foreground)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.widthAnchor.constraint(equalToConstant: 14).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 14).isActive = true
            contentStack.addArrangedSubview(iconView)
        }
        contentStack.addArrangedSubview(label)

        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 6
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 34),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let contentStack = UIStackView()

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
