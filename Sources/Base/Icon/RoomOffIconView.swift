import UIKit

public final class RoomOffIconView: UIView {

    private let bodyView = RoomIcon()
    private let slashView = UIImageView()
    private var unsubscribe: (() -> Void)?

    public init(iconName: String, side: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        bodyView.image = RoomKitResources.image(named: "\(iconName)_body")
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bodyView)

        slashView.image = RoomKitResources.image(named: "\(iconName)_slash")?.withRenderingMode(.alwaysTemplate)
        slashView.contentMode = .scaleAspectFit
        slashView.tintColor = ThemeStore.shared.theme.icoSlash
        slashView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slashView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: side),
            heightAnchor.constraint(equalToConstant: side),
            bodyView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bodyView.topAnchor.constraint(equalTo: topAnchor),
            bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            slashView.leadingAnchor.constraint(equalTo: leadingAnchor),
            slashView.trailingAnchor.constraint(equalTo: trailingAnchor),
            slashView.topAnchor.constraint(equalTo: topAnchor),
            slashView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            unsubscribe = ThemeStore.shared.subscribe { [weak self] theme in
                self?.slashView.tintColor = theme.icoSlash
            }
        } else {
            unsubscribe?()
            unsubscribe = nil
        }
    }
}
