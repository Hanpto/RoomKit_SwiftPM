import UIKit

public final class RoomLoading: UIViewController {

    public enum Variant {
        case card
        case plain
    }

    private let message: String?
    private let variant: Variant

    public static func show(
        in presenter: UIViewController,
        text: String? = nil,
        variant: Variant = .card
    ) -> RoomLoading {
        let controller = RoomLoading(text: text, variant: variant)
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        presenter.present(controller, animated: true)
        return controller
    }

    private init(text: String?, variant: Variant) {
        self.message = text
        self.variant = variant
        super.init(nibName: nil, bundle: nil)
        modalPresentationCapturesStatusBarAppearance = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        let theme = ThemeStore.shared.theme
        view.backgroundColor = theme.bgOverlay

        let holder = UIStackView()
        holder.axis = .vertical
        holder.alignment = .center
        holder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(holder)

        let spinner = RoomSpinner()
        spinner.color = theme.accent
        spinner.translatesAutoresizingMaskIntoConstraints = false
        holder.addArrangedSubview(spinner)

        NSLayoutConstraint.activate([
            holder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            holder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinner.widthAnchor.constraint(equalToConstant: 48),
            spinner.heightAnchor.constraint(equalToConstant: 48),
        ])

        if variant == .card {
            holder.isLayoutMarginsRelativeArrangement = true
            holder.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 20)
            holder.layer.cornerRadius = 12
            holder.backgroundColor = theme.bgSurface
        }

        if let message, !message.isEmpty {
            let label = UILabel()
            label.text = message
            label.textColor = theme.fgPrimary
            label.font = .systemFont(ofSize: 14)
            label.textAlignment = .center
            label.numberOfLines = 0
            holder.addArrangedSubview(label)
            holder.setCustomSpacing(12, after: spinner)
        }
    }

    public func dismissLoading() {
        dismiss(animated: true)
    }
}
