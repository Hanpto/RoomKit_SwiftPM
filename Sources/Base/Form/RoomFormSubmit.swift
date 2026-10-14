import UIKit
import SnapKit

final class RoomFormSubmit: UIControl {

    var text: String? {
        didSet { label.text = text }
    }

    var isLoading: Bool = false {
        didSet {
            isEnabled = !isLoading
            alpha = isLoading ? ThemeStore.shared.theme.disabledOpacity : 1
        }
    }

    var onTap: (() -> Void)?

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.88 : (isEnabled ? 1 : ThemeStore.shared.theme.disabledOpacity) }
    }

    private let label = UILabel()
    private var themeUnsubscribe: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupStyles()
        setupBindings()
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

    private func setupViews() {
        layer.cornerRadius = RoomTokens.Radius.smDP
        layer.masksToBounds = true
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        addSubview(label)
    }

    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }

    private func setupStyles() {
        applyTheme()
    }

    private func setupBindings() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    private func applyTheme() {
        let theme = ThemeStore.shared.theme
        backgroundColor = theme.accent
        label.textColor = theme.fgOnAccent
    }

    @objc private func handleTap() {
        onTap?()
    }
}
