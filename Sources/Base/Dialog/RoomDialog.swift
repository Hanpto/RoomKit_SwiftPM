import UIKit

public final class RoomDialog: UIViewController {

    public struct Config {
        public let title: String?
        public let message: String?
        public let contentView: UIView?
        public let primaryText: String?
        public let primaryVariant: RoomButton.Variant
        public let onPrimary: (() -> Void)?
        public let secondaryText: String?
        public let onSecondary: (() -> Void)?
        public let onCancel: (() -> Void)?
        public let cancelable: Bool
        public let closable: Bool
    }

    public final class Builder {
        private weak var presenter: UIViewController?
        private var titleText: String?
        private var messageText: String?
        private var contentView: UIView?
        private var primaryText: String?
        private var primaryVariant: RoomButton.Variant = .primary
        private var onPrimary: (() -> Void)?
        private var secondaryText: String?
        private var onSecondary: (() -> Void)?
        private var onCancel: (() -> Void)?
        private var cancelable = true
        private var closable = true

        public init(in presenter: UIViewController) {
            self.presenter = presenter
        }

        public func title(_ text: String?) -> Builder {
            titleText = text
            return self
        }

        public func message(_ text: String?) -> Builder {
            messageText = text
            return self
        }

        public func contentView(_ view: UIView?) -> Builder {
            contentView = view
            return self
        }

        public func cancelable(_ value: Bool) -> Builder {
            cancelable = value
            return self
        }

        public func closable(_ value: Bool) -> Builder {
            closable = value
            return self
        }

        public func onCancel(_ action: @escaping () -> Void) -> Builder {
            onCancel = action
            return self
        }

        public func primaryAction(
            _ text: String,
            variant: RoomButton.Variant = .primary,
            onTap: @escaping () -> Void = {}
        ) -> Builder {
            primaryText = text
            primaryVariant = variant
            onPrimary = onTap
            return self
        }

        public func secondaryAction(_ text: String, onTap: @escaping () -> Void = {}) -> Builder {
            secondaryText = text
            onSecondary = onTap
            return self
        }

        public func build() -> RoomDialog {
            RoomDialog(
                config: Config(
                    title: titleText,
                    message: messageText,
                    contentView: contentView,
                    primaryText: primaryText,
                    primaryVariant: primaryVariant,
                    onPrimary: onPrimary,
                    secondaryText: secondaryText,
                    onSecondary: onSecondary,
                    onCancel: onCancel,
                    cancelable: cancelable,
                    closable: closable
                )
            )
        }

        @discardableResult
        public func show() -> RoomDialog {
            let dialog = build()
            if let presenter {
                presenter.present(dialog, animated: true)
            }
            return dialog
        }
    }

    private let config: Config

    private init(config: Config) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        let theme = ThemeStore.shared.theme
        view.backgroundColor = theme.bgOverlay

        if config.cancelable {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap)))
        }

        let card = UIView()
        card.backgroundColor = theme.bgSurface
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(contentStack)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64),
            contentStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])

        if config.title != nil || config.closable {
            contentStack.addArrangedSubview(makeHead())
        }

        if let message = config.message {
            if let previous = contentStack.arrangedSubviews.last {
                contentStack.setCustomSpacing(8, after: previous)
            }
            let label = makeLabel(text: message, color: theme.fgSecondary, font: .systemFont(ofSize: 13))
            label.numberOfLines = 0
            contentStack.addArrangedSubview(label)
        }

        if let contentView = config.contentView {
            if let previous = contentStack.arrangedSubviews.last {
                contentStack.setCustomSpacing(12, after: previous)
            }
            contentStack.addArrangedSubview(contentView)
        }

        if config.primaryText != nil || config.secondaryText != nil {
            if let previous = contentStack.arrangedSubviews.last {
                contentStack.setCustomSpacing(16, after: previous)
            }
            contentStack.addArrangedSubview(makeActions())
        }
    }

    @objc private func handleBackgroundTap() {
        cancelDialog()
    }

    private func cancelDialog() {
        config.onCancel?()
        dismiss(animated: true)
    }

    private func makeHead() -> UIView {
        let head = UIStackView()
        head.axis = .horizontal
        head.alignment = .center

        if let title = config.title {
            let label = makeLabel(text: title, color: ThemeStore.shared.theme.fgPrimary, font: .boldSystemFont(ofSize: 16))
            label.setContentHuggingPriority(.required, for: .horizontal)
            head.addArrangedSubview(label)
            if config.closable {
                head.setCustomSpacing(8, after: label)
            }
        }
        if config.closable {
            let closeButton = DialogCloseButton()
            closeButton.addAction(UIAction { [weak self] _ in
                self?.cancelDialog()
            }, for: .touchUpInside)
            head.addArrangedSubview(closeButton)
        }
        return head
    }

    private func makeLabel(text: String, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = font
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }

    private func makeActions() -> UIStackView {
        let actions = UIStackView()
        actions.axis = .horizontal
        actions.distribution = .fillEqually
        actions.spacing = 8

        if let secondaryText = config.secondaryText {
            let button = RoomButton()
            button.variant = .ghost
            button.text = secondaryText
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.addAction(
                UIAction { [weak self] _ in
                    self?.config.onSecondary?()
                    self?.dismiss(animated: true)
                },
                for: .touchUpInside
            )
            actions.addArrangedSubview(button)
        }

        if let primaryText = config.primaryText {
            let button = RoomButton()
            button.variant = config.primaryVariant
            button.text = primaryText
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.addAction(
                UIAction { [weak self] _ in
                    self?.config.onPrimary?()
                },
                for: .touchUpInside
            )
            actions.addArrangedSubview(button)
        }
        return actions
    }
}

private final class DialogCloseButton: UIControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        clipsToBounds = true

        let iconView = RoomIcon()
        iconView.image = RoomKitResources.image(named: "roomkit_icon_close")
        iconView.setImageTint(ThemeStore.shared.theme.fgSecondary)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 28),
            heightAnchor.constraint(equalToConstant: 28),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? ThemeStore.shared.theme.bgHover : .clear
        }
    }
}
