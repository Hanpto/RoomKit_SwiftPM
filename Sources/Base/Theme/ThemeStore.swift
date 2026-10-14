import UIKit

public final class ThemeStore {

    public static let shared = ThemeStore()

    public private(set) var mode: RoomTheme.Mode = .light
    public private(set) var accent: UIColor = RoomAccent.defaultAccent
    public private(set) var isFollowSystem = false

    public var theme: RoomTheme { RoomTheme.of(mode, accent: accent) }

    private var observers: [UUID: (RoomTheme) -> Void] = [:]
    private var systemStyleObserver: SystemStyleObserverView?

    private init() {}

    public func setMode(_ mode: RoomTheme.Mode) {
        if self.mode == mode && !isFollowSystem { return }
        isFollowSystem = false
        if self.mode == mode { return }
        self.mode = mode
        notifyChanged()
    }

    public func setAccent(_ color: UIColor) {
        if accent == color { return }
        accent = color
        notifyChanged()
    }

    public func followSystem() {
        isFollowSystem = true
        installSystemStyleObserver()
        applySystemStyle(currentSystemStyle)
    }

    @discardableResult
    public func subscribe(_ observer: @escaping (RoomTheme) -> Void) -> () -> Void {
        let id = UUID()
        observers[id] = observer
        observer(theme)
        return { [weak self] in self?.observers[id] = nil }
    }

    private var currentSystemStyle: UIUserInterfaceStyle {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let windows = scenes.flatMap { $0.windows }
        let style = windows.first { $0.isKeyWindow }?.traitCollection.userInterfaceStyle
            ?? scenes.first?.traitCollection.userInterfaceStyle
            ?? .unspecified
        return style
    }

    private func installSystemStyleObserver() {
        guard systemStyleObserver == nil else { return }
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        guard let window = scenes.flatMap({ $0.windows }).first(where: { $0.isKeyWindow }) else { return }
        let observerView = SystemStyleObserverView(frame: .zero)
        observerView.isHidden = true
        window.addSubview(observerView)
        observerView.onStyleChanged = { [weak self] style in self?.applySystemStyle(style) }
        systemStyleObserver = observerView
    }

    private func applySystemStyle(_ style: UIUserInterfaceStyle) {
        guard isFollowSystem else { return }
        let target: RoomTheme.Mode
        switch style {
        case .dark: target = .dark
        case .light: target = .light
        default: return
        }
        if mode == target { return }
        mode = target
        notifyChanged()
    }

    private func notifyChanged() {
        let current = theme
        observers.values.forEach { $0(current) }
    }
}

private final class SystemStyleObserverView: UIView {
    var onStyleChanged: ((UIUserInterfaceStyle) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
                self.onStyleChanged?(self.traitCollection.userInterfaceStyle)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(iOS, deprecated: 17.0)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17.0) {
            onStyleChanged?(traitCollection.userInterfaceStyle)
        }
    }
}
