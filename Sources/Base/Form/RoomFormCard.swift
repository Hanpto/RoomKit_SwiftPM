import UIKit
import SnapKit

final class RoomFormCard: UIView {

    private let stack = UIStackView()
    private var themeUnsubscribe: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupStyles()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            themeUnsubscribe = ThemeStore.shared.subscribe { [weak self] _ in
                self?.setupStyles()
            }
        } else {
            themeUnsubscribe?()
            themeUnsubscribe = nil
        }
    }

    func addRow(_ row: UIView) {
        stack.addArrangedSubview(row)
    }

    private func setupViews() {
        layer.cornerRadius = RoomTokens.Radius.controlDP
        layer.masksToBounds = true
        stack.axis = .vertical
        stack.distribution = .fill
        addSubview(stack)
    }

    private func setupConstraints() {
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
    }

    private func setupStyles() {
        backgroundColor = ThemeStore.shared.theme.bgSurface
    }
}
