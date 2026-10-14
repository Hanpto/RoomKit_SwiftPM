import UIKit
import SnapKit

final class RoomFormRow: UIView {

    private let titleLabel = UILabel()
    private let content: UIView
    private var themeUnsubscribe: (() -> Void)?

    init(title: String, field: UITextField) {
        content = field
        super.init(frame: .zero)
        titleLabel.text = title
        setupViews(trailingAligned: false)
        applyTheme()
    }

    init(title: String, control: UIControl) {
        content = control
        super.init(frame: .zero)
        titleLabel.text = title
        setupViews(trailingAligned: true)
        applyTheme()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            themeUnsubscribe = ThemeStore.shared.subscribe { [weak self] _ in
                self?.applyTheme()
            }
        } else {
            themeUnsubscribe?()
            themeUnsubscribe = nil
        }
    }

    func applyTheme() {
        let theme = ThemeStore.shared.theme
        titleLabel.textColor = theme.fgPrimary
        guard let field = content as? UITextField else { return }
        field.font = .systemFont(ofSize: 15)
        field.textColor = theme.fgSecondary
        field.textAlignment = .right
        field.attributedPlaceholder = NSAttributedString(
            string: field.placeholder ?? "",
            attributes: [.foregroundColor: theme.fgTertiary]
        )
    }

    private func setupViews(trailingAligned: Bool) {
        titleLabel.font = .systemFont(ofSize: 15)
        addSubview(titleLabel)
        addSubview(content)

        snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(56)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(88)
        }
        if trailingAligned {
            content.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        } else {
            content.snp.makeConstraints {
                $0.leading.equalTo(titleLabel.snp.trailing).offset(16)
                $0.trailing.equalToSuperview()
                $0.centerY.equalToSuperview()
                $0.height.equalTo(32)
            }
        }
    }
}
