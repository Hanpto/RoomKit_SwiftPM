import UIKit
import SnapKit

final class RoomHomeEntryCard: UIControl {

    enum Tone {
        case create
        case join
        case schedule
    }

    var onTap: (() -> Void)?

    private let tone: Tone
    private var themeUnsubscribe: (() -> Void)?

    private let iconCircle = UIView()
    private let iconGradientLayer = CAGradientLayer()
    private let iconWell = UIView()
    private let iconView = RoomIcon()
    private let titleLabel = UILabel()

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.82 : 1
            transform = isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 96)
    }

    init(tone: Tone) {
        self.tone = tone
        super.init(frame: .zero)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        iconGradientLayer.frame = iconCircle.bounds
        iconGradientLayer.cornerRadius = iconCircle.bounds.width / 2
    }

    private func setupViews() {
        [iconCircle, iconWell, iconView, titleLabel].forEach {
            $0.isUserInteractionEnabled = false
        }

        iconCircle.layer.insertSublayer(iconGradientLayer, at: 0)
        iconCircle.layer.masksToBounds = true
        addSubview(iconCircle)

        iconWell.layer.cornerRadius = 6
        iconWell.isHidden = tone != .join
        iconCircle.addSubview(iconWell)
        iconWell.addSubview(iconView)

        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)
    }

    private func setupConstraints() {
        iconCircle.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.size.equalTo(68)
        }
        iconCircle.layer.cornerRadius = 34

        iconWell.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(22)
        }

        if tone == .join {
            iconView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.size.equalTo(6)
            }
        } else {
            iconCircle.addSubview(iconView)
            iconView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.size.equalTo(22)
            }
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconCircle.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(18)
        }
    }

    private func setupStyles() {
        switch tone {
        case .create:
            iconView.image = RoomKitResources.image(named: "roomkit_icon_entry_create")
            titleLabel.text = .homeQuickMeeting
        case .join:
            iconView.image = RoomKitResources.image(named: "roomkit_icon_entry_join")
            titleLabel.text = .homeJoinMeeting
        case .schedule:
            iconView.image = RoomKitResources.image(named: "roomkit_icon_entry_schedule")
            titleLabel.text = .homeScheduleMeeting
        }
        iconGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        iconGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        applyTheme()
    }

    private func setupBindings() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    private func applyTheme() {
        let theme = ThemeStore.shared.theme
        titleLabel.textColor = theme.fgPrimary

        // 三个入口统一使用主色渐变（对齐设计稿 entry-icon--create/join/schedule）。
        iconGradientLayer.colors = [
            ColorMix.blend(theme.accent, theme.fgOnAccent, 0.78).cgColor,
            theme.accent.cgColor,
        ]

        if tone == .join {
            iconWell.backgroundColor = theme.fgOnAccent
            iconView.setImageTint(theme.accent)
        } else {
            iconView.setImageTint(theme.fgOnAccent)
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}

extension String {
    fileprivate static let homeQuickMeeting = RoomKitResources.localizedString("roomkit.home.quick_meeting")
    fileprivate static let homeJoinMeeting = RoomKitResources.localizedString("roomkit.home.join_meeting")
    fileprivate static let homeScheduleMeeting = RoomKitResources.localizedString("roomkit.home.schedule_meeting")
}
