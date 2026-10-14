import UIKit
import SnapKit

/// 首页「日程」区块（对齐设计稿 `.recent`）：标题行（主色竖条 + 文案）+ 列表区。
/// 目前还没有日程数据源，列表区只展示空态（对齐 `rk-cal-empty`：插画 + 文案）。
final class RoomHomeAgendaView: UIView {

    private var themeUnsubscribe: (() -> Void)?
    private var isLoggedIn = true

    private let titleBar = UIView()
    private let titleLabel = UILabel()
    private let emptyStack = UIStackView()
    private let emptyArt = UIImageView()
    private let emptyLabel = UILabel()

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
                self?.applyTheme()
            }
        } else {
            themeUnsubscribe?()
            themeUnsubscribe = nil
        }
    }

    private func setupViews() {
        emptyStack.addArrangedSubview(emptyArt)
        emptyStack.addArrangedSubview(emptyLabel)
        addSubview(titleBar)
        addSubview(titleLabel)
        addSubview(emptyStack)
    }

    private func setupConstraints() {
        // .section-row：padding 14 16 8，竖条 3x12，gap 8。
        titleBar.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(CGSize(width: 3, height: 12))
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalTo(titleBar.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        // .rk-cal-empty：列表区内上 12 / 下 64 的内边距内水平垂直居中。
        // 标题行高约 41（14 + 19 + 8），故内容中心 ≈ 本视图中心 - 5。
        emptyStack.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(8 + 12)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-5)
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        // 插画宽 min(232, 78%)，宽高比 2:1；宽度相对本视图，避免与 stack 自身宽度循环依赖。
        emptyArt.snp.makeConstraints {
            $0.width.equalTo(self).multipliedBy(0.78).priority(.high)
            $0.width.lessThanOrEqualTo(232)
            $0.height.equalTo(emptyArt.snp.width).multipliedBy(0.5)
        }
    }

    private func setupStyles() {
        // .recent：bg-surface 底色 + radius-lg(20) 圆角，裁切内容。
        layer.cornerRadius = 20
        layer.masksToBounds = true

        titleBar.layer.cornerRadius = 1.5
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.text = .homeAgenda

        emptyArt.image = RoomKitResources.image(named: "roomkit_image_agenda_empty")
        emptyArt.contentMode = .scaleAspectFit

        emptyStack.axis = .vertical
        emptyStack.alignment = .center
        emptyStack.spacing = 12
        emptyLabel.font = .systemFont(ofSize: 15)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0

        updateEmptyText()
        applyTheme()
    }

    private func applyTheme() {
        let theme = ThemeStore.shared.theme
        backgroundColor = theme.bgSurface
        titleBar.backgroundColor = theme.accent
        titleLabel.textColor = theme.fgPrimary
        emptyLabel.textColor = theme.fgSecondary
    }

    private func updateEmptyText() {
        emptyLabel.text = isLoggedIn ? .homeAgendaEmpty : .homeAgendaLoginToView
    }
}

// MARK: - public methods

extension RoomHomeAgendaView {

    /// 未登录显示「登录后查看」，已登录显示「暂无近期会议」。
    func setLoggedIn(_ loggedIn: Bool) {
        isLoggedIn = loggedIn
        updateEmptyText()
    }
}

extension String {
    fileprivate static let homeAgenda = RoomKitResources.localizedString("roomkit.home.agenda")
    fileprivate static let homeAgendaEmpty = RoomKitResources.localizedString("roomkit.home.agenda_empty")
    fileprivate static let homeAgendaLoginToView = RoomKitResources.localizedString("roomkit.home.agenda_login_to_view")
}
