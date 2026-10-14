import UIKit
import SnapKit
import Combine
import AtomicXCore

public final class JoinMeetingView: UIView {

    public enum Mode {
        case `default`
    }

    public weak var routerContext: RouterContext?
    public var onEnterRoom: ((String) -> Void)?

    private let mode: Mode
    private var isSubmitting = false
    private var cancellableSet = Set<AnyCancellable>()
    private var themeUnsubscribe: (() -> Void)?

    private let navBar = UIView()
    private let cancelButton = UIButton(type: .system)
    private let navTitleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let roomCard = RoomFormCard()
    private let roomField = UITextField()

    private let mediaCard = RoomFormCard()
    private let micSwitch = RoomSwitch()
    private let speakerSwitch = RoomSwitch()
    private let cameraSwitch = RoomSwitch()

    private let submitButton = RoomFormSubmit()

    private lazy var roomRow = RoomFormRow(title: .joinRoomId, field: roomField)

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

        roomCard.addRow(roomRow)
        contentView.addSubview(roomCard)

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
        roomCard.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        mediaCard.snp.makeConstraints {
            $0.top.equalTo(roomCard.snp.bottom).offset(12)
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

        navTitleLabel.text = .joinNavTitle
        navTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        roomField.keyboardType = .numberPad
        roomField.returnKeyType = .done
        roomField.autocorrectionType = .no
        roomField.autocapitalizationType = .none
        roomField.placeholder = .joinRoomIdPlaceholder

        submitButton.text = .joinNavTitle

        applyTheme()
    }

    private func setupBindings() {
        cancelButton.addTarget(self, action: #selector(handleCancelTap), for: .touchUpInside)
        submitButton.onTap = { [weak self] in self?.submitJoin() }
        roomField.delegate = self

        micSwitch.isChecked = true
        speakerSwitch.isChecked = true
        cameraSwitch.isChecked = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBlankTap))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    private func submitJoin() {
        guard !isSubmitting else { return }
        let roomID = roomField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !roomID.isEmpty else {
            RoomToast.show(.joinInvalidRoomId)
            return
        }
        isSubmitting = true
        submitButton.isLoading = true
        RoomStore.shared.joinRoom(roomID: roomID, roomType: .standard, password: nil) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isSubmitting = false
                self.submitButton.isLoading = false
                switch result {
                case .success:
                    self.applyLocalMedia()
                    self.onEnterRoom?(roomID)
                case .failure(let error):
                    RoomToast.show(RoomKitResources.localizedFormat("roomkit.join.join_failed", error.message))
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

extension JoinMeetingView {

    @objc private func handleCancelTap() {
        routerContext?.pop(animated: true)
    }

    @objc private func handleBlankTap() {
        endEditing(true)
    }
}

extension JoinMeetingView: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submitJoin()
        return true
    }
}

extension String {
    fileprivate static let commonCancel = RoomKitResources.localizedString("roomkit.common.cancel")
    fileprivate static let joinNavTitle = RoomKitResources.localizedString("roomkit.join.nav_title")
    fileprivate static let joinRoomId = RoomKitResources.localizedString("roomkit.join.room_id")
    fileprivate static let joinRoomIdPlaceholder = RoomKitResources.localizedString("roomkit.join.room_id_placeholder")
    fileprivate static let joinInvalidRoomId = RoomKitResources.localizedString("roomkit.join.invalid_room_id")
    fileprivate static let preMicOn = RoomKitResources.localizedString("roomkit.pre.mic_on")
    fileprivate static let preSpeakerOn = RoomKitResources.localizedString("roomkit.pre.speaker_on")
    fileprivate static let preCameraOn = RoomKitResources.localizedString("roomkit.pre.camera_on")
}
