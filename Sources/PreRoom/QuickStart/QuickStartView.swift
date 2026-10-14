import UIKit
import SnapKit
import Combine
import AtomicXCore

public final class QuickStartView: UIView {

    public enum Mode {
        case `default`
    }

    public weak var routerContext: RouterContext?
    public var onEnterRoom: ((String) -> Void)?

    private let mode: Mode
    private var isSubmitting = false
    private var displayName = ""
    private var cancellableSet = Set<AnyCancellable>()
    private var themeUnsubscribe: (() -> Void)?

    private let navBar = UIView()
    private let cancelButton = UIButton(type: .system)
    private let navTitleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameCard = RoomFormCard()
    private let nameField = UITextField()

    private let mediaCard = RoomFormCard()
    private let micSwitch = RoomSwitch()
    private let speakerSwitch = RoomSwitch()
    private let cameraSwitch = RoomSwitch()

    private let submitButton = RoomFormSubmit()

    private lazy var nameRow = RoomFormRow(title: .quickStartMeetingName, field: nameField)

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
        navBar.addSubview(cancelButton)
        navBar.addSubview(navTitleLabel)
        addSubview(navBar)

        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.addSubview(contentView)
        addSubview(scrollView)

        nameCard.addRow(nameRow)
        contentView.addSubview(nameCard)

        micSwitch.size = .lg
        speakerSwitch.size = .lg
        cameraSwitch.size = .lg
        mediaCard.addRow(RoomFormRow(title: .preMicOn, control: micSwitch))
        mediaCard.addRow(RoomFormRow(title: .preSpeakerOn, control: speakerSwitch))
        mediaCard.addRow(RoomFormRow(title: .preCameraOn, control: cameraSwitch))
        contentView.addSubview(mediaCard)

        addSubview(submitButton)
    }

    private func setupConstraints() {
        navBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(44)
        }
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalTo(safeAreaLayoutGuide.snp.top).offset(22)
        }
        navTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(safeAreaLayoutGuide.snp.top).offset(22)
            $0.centerX.equalToSuperview()
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(navBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(submitButton.snp.top).offset(-8)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        nameCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        mediaCard.snp.makeConstraints {
            $0.top.equalTo(nameCard.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.lessThanOrEqualToSuperview().offset(-16)
        }

        submitButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
    }

    private func setupStyles() {
        cancelButton.setTitle(.commonCancel, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 15)

        navTitleLabel.text = .quickStartNavTitle
        navTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        nameField.returnKeyType = .done
        nameField.autocorrectionType = .no
        nameField.autocapitalizationType = .none

        submitButton.text = .quickStartNavTitle

        applyTheme()
    }

    private func setupBindings() {
        cancelButton.addTarget(self, action: #selector(handleCancelTap), for: .touchUpInside)
        submitButton.onTap = { [weak self] in self?.submitQuickStart() }
        nameField.addTarget(self, action: #selector(handleFieldDone), for: .editingDidEndOnExit)

        micSwitch.isChecked = true
        speakerSwitch.isChecked = true
        cameraSwitch.isChecked = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBlankTap))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)

        LoginStore.shared.state
            .subscribe(StatePublisherSelector(projector: { state in
                guard state.loginStatus == .logined, let profile = state.loginUserInfo else { return "" }
                if let nickname = profile.nickname, !nickname.isEmpty { return nickname }
                return profile.userID
            }))
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                guard let self else { return }
                self.displayName = name
                self.nameField.placeholder = RoomKitResources.localizedFormat("roomkit.quick_start.title_placeholder", name)
                self.nameRow.applyTheme()
            }
            .store(in: &cancellableSet)
    }

    private func resolvedRoomName() -> String {
        let typed = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !typed.isEmpty { return typed }
        return RoomKitResources.localizedFormat("roomkit.quick_start.title_placeholder", displayName)
    }

    private func submitQuickStart() {
        guard !isSubmitting else { return }
        isSubmitting = true
        submitButton.isLoading = true
        let roomID = RoomRandomUtils.roomID()
        var options = CreateRoomOptions()
        options.roomName = resolvedRoomName()
        RoomStore.shared.createAndJoinRoom(roomID: roomID, roomType: .standard, options: options) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isSubmitting = false
                self.submitButton.isLoading = false
                switch result {
                case .success:
                    self.applyLocalMedia()
                    self.onEnterRoom?(roomID)
                case .failure(let error):
                    RoomToast.show(RoomKitResources.localizedFormat("roomkit.quick_start.create_failed", error.message))
                }
            }
        }
    }

    private func applyTheme() {
        let theme = ThemeStore.shared.theme
        backgroundColor = theme.bgCanvas
        navBar.backgroundColor = theme.bgSurface
        cancelButton.setTitleColor(theme.fgTertiary, for: .normal)
        navTitleLabel.textColor = theme.fgPrimary
    }

    private func applyLocalMedia() {
        if !micSwitch.isChecked { DeviceStore.shared.closeLocalMicrophone() }
        if !cameraSwitch.isChecked { DeviceStore.shared.closeLocalCamera() }
        DeviceStore.shared.setAudioRoute(speakerSwitch.isChecked ? .speakerphone : .earpiece)
    }
}

extension QuickStartView {

    @objc private func handleCancelTap() {
        routerContext?.pop(animated: true)
    }

    @objc private func handleBlankTap() {
        endEditing(true)
    }

    @objc private func handleFieldDone() {
        nameField.resignFirstResponder()
    }
}

extension String {
    fileprivate static let commonCancel = RoomKitResources.localizedString("roomkit.common.cancel")
    fileprivate static let quickStartNavTitle = RoomKitResources.localizedString("roomkit.quick_start.nav_title")
    fileprivate static let quickStartMeetingName = RoomKitResources.localizedString("roomkit.quick_start.meeting_name")
    fileprivate static let preMicOn = RoomKitResources.localizedString("roomkit.pre.mic_on")
    fileprivate static let preSpeakerOn = RoomKitResources.localizedString("roomkit.pre.speaker_on")
    fileprivate static let preCameraOn = RoomKitResources.localizedString("roomkit.pre.camera_on")
}
