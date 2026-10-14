import UIKit
import SnapKit
import Combine
import AtomicXCore

public final class RoomHomeView: UIView {

    public enum Mode {
        case `default`
    }

    public weak var routerContext: RouterContext?

    public var onAvatarTapped: (() -> Void)?
    public var onLoginTapped: (() -> Void)?

    private let mode: Mode
    private var cancellableSet = Set<AnyCancellable>()
    private var themeUnsubscribe: (() -> Void)?

    private let avatarButton = UIButton(type: .custom)
    private let avatarView = RoomAvatar()
    private let nameLabel = UILabel()
    private let loginChip = UIButton(type: .custom)

    private let entryStack = UIStackView()
    private let createEntry = RoomHomeEntryCard(tone: .create)
    private let joinEntry = RoomHomeEntryCard(tone: .join)
    private let scheduleEntry = RoomHomeEntryCard(tone: .schedule)

    private let agendaView = RoomHomeAgendaView()

    public init(mode: Mode) {
        self.mode = mode
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
        setupStyles()
        setupBindings()
    }

    public convenience init() {
        self.init(mode: .default)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToWindow() {
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
        avatarView.isUserInteractionEnabled = false
        avatarButton.addSubview(avatarView)
        addSubview(avatarButton)
        addSubview(nameLabel)
        addSubview(loginChip)

        entryStack.axis = .horizontal
        entryStack.distribution = .fillEqually
        entryStack.alignment = .top
        entryStack.addArrangedSubview(createEntry)
        entryStack.addArrangedSubview(joinEntry)
        entryStack.addArrangedSubview(scheduleEntry)
        addSubview(entryStack)
        addSubview(agendaView)
    }

    private func setupConstraints() {
        avatarButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(32)
        }
        avatarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarButton.snp.trailing).offset(8)
            $0.centerY.equalTo(avatarButton)
        }
        loginChip.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(avatarButton)
            $0.height.equalTo(28)
            $0.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(8)
        }

        entryStack.snp.makeConstraints {
            $0.top.equalTo(avatarButton.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // .recent：margin 16 12；上方还有 .entry-row 的下内边距 12（flex 外边距不合并），
        // 故卡片顶部距入口行 28；占满剩余空间，底部避开 Home 指示条。
        agendaView.snp.makeConstraints {
            $0.top.equalTo(entryStack.snp.bottom).offset(12 + 16)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }
    }

    private func setupStyles() {
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.lineBreakMode = .byTruncatingTail

        loginChip.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        loginChip.setTitle(.homeLoginSignup, for: .normal)
        loginChip.layer.cornerRadius = 14
        loginChip.layer.borderWidth = 1
        loginChip.contentEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)

        applyTheme()
    }

    private func setupBindings() {
        avatarButton.addTarget(self, action: #selector(handleAvatarTap), for: .touchUpInside)
        loginChip.addTarget(self, action: #selector(handleLoginTap), for: .touchUpInside)
        createEntry.onTap = { [weak self] in
            self?.routerContext?.push(QuickStartViewController(), animated: true)
        }
        joinEntry.onTap = { [weak self] in
            self?.routerContext?.push(JoinMeetingViewController(), animated: true)
        }
        scheduleEntry.onTap = {
            // 预约会议页尚未接入。
            RoomToast.show(.homeFeatureComing)
        }

        LoginStore.shared.state
            .subscribe(StatePublisherSelector(projector: { state in
                state.loginStatus == .logined ? state.loginUserInfo : nil
            }))
            .receive(on: RunLoop.main)
            .sink { [weak self] profile in
                self?.applyLoginState(profile)
            }
            .store(in: &cancellableSet)
    }

    private func applyTheme() {
        let theme = ThemeStore.shared.theme
        backgroundColor = theme.bgCanvas
        nameLabel.textColor = theme.fgPrimary

        loginChip.setTitleColor(theme.accent, for: .normal)
        loginChip.backgroundColor = theme.accentSoft
        loginChip.layer.borderColor = ColorMix.withAlpha(theme.accent, 0.35).cgColor
    }

    private func applyLoginState(_ profile: UserProfile?) {
        let loggedIn = profile != nil
        avatarButton.isHidden = !loggedIn
        nameLabel.isHidden = !loggedIn
        loginChip.isHidden = loggedIn
        agendaView.setLoggedIn(loggedIn)

        let displayName: String
        if let nickname = profile?.nickname, !nickname.isEmpty {
            displayName = nickname
        } else {
            displayName = profile?.userID ?? ""
        }
        nameLabel.text = displayName
        avatarView.text = displayName
        avatarView.url = profile?.avatarURL
    }
}

extension RoomHomeView {

    @objc private func handleAvatarTap() {
        onAvatarTapped?()
    }

    @objc private func handleLoginTap() {
        onLoginTapped?()
    }
}

extension String {
    fileprivate static let homeLoginSignup = RoomKitResources.localizedString("roomkit.home.login_signup")
    fileprivate static let homeFeatureComing = RoomKitResources.localizedString("roomkit.main.feature_coming")
}
