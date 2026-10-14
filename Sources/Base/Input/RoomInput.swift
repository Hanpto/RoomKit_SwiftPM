import UIKit

public final class RoomInput: UIView {

    public enum Variant {
        case outlined
        case filled
    }

    public enum Size {
        case sm
        case md
        case lg

        var heightPt: CGFloat {
            switch self {
            case .sm: return 32
            case .md, .lg: return 44
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .sm: return 13
            case .md, .lg: return 15
            }
        }

        var iconPt: CGFloat {
            switch self {
            case .sm: return 16
            case .md, .lg: return 18
            }
        }
    }

    public enum InputType {
        case text
        case password
        case textarea
    }

    public var text: String {
        get { field.text ?? "" }
        set {
            let next = newValue
            guard field.text ?? "" != next else { return }
            field.text = next
            field.setCursor(position: (next as NSString).length)
        }
    }

    public var hint: String? {
        didSet { field.placeholder = hint }
    }

    public var variant: Variant = .outlined {
        didSet {
            guard oldValue != variant else { return }
            applyStyle()
        }
    }

    public var size: Size = .md {
        didSet {
            guard oldValue != size else { return }
            applyStyle()
        }
    }

    public var type: InputType = .text {
        didSet {
            guard oldValue != type else { return }
            applyType()
        }
    }

    public var icon: UIImage? {
        didSet {
            guard oldValue !== icon else { return }
            leadingIcon.image = icon
            leadingIcon.isHidden = icon == nil
            applyStyle()
        }
    }

    public func setIconNamed(_ name: String) {
        icon = RoomKitResources.image(named: name)
    }

    public var isClearable: Bool = false {
        didSet {
            guard oldValue != isClearable else { return }
            applyClearState()
        }
    }

    public var maxLength: Int = -1 {
        didSet {
            guard oldValue != maxLength else { return }
        }
    }

    public var error: String? {
        didSet {
            guard oldValue != error else { return }
            applyStyle()
        }
    }

    public var onTextChanged: ((String) -> Void)?
    public var onSubmit: (() -> Void)?
    public var onFocusChange: ((Bool) -> Void)?

    public var isEnabled: Bool = true {
        didSet {
            guard oldValue != isEnabled else { return }
            isUserInteractionEnabled = isEnabled
            field.isEnabled = isEnabled
            alpha = isEnabled ? 1 : ThemeStore.shared.theme.disabledOpacity
        }
    }

    private let rowView = UIView()
    private let leadingIcon = RoomIcon()
    private let field = UITextField()
    private let clearButton = RoomIcon()
    private let errorLabel = UILabel()
    private var rowHeightConstraint: NSLayoutConstraint!
    private var iconWidthConstraint: NSLayoutConstraint!
    private var iconHeightConstraint: NSLayoutConstraint!
    private var isFieldFocused = false
    private var unsubscribe: (() -> Void)?

    override public init(frame: CGRect) {
        leadingIcon.isHidden = true
        leadingIcon.isUserInteractionEnabled = false

        field.font = .systemFont(ofSize: 15)
        field.borderStyle = .none
        field.returnKeyType = .done

        clearButton.isHidden = true
        clearButton.image = RoomKitResources.image(named: "roomkit_icon_close")
        clearButton.isUserInteractionEnabled = true

        errorLabel.font = .systemFont(ofSize: 12)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        let row = UIStackView(arrangedSubviews: [leadingIcon, field, clearButton])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        row.translatesAutoresizingMaskIntoConstraints = false
        rowView.addSubview(row)
        rowView.layer.cornerRadius = 12
        rowView.translatesAutoresizingMaskIntoConstraints = false

        let container = UIStackView(arrangedSubviews: [rowView, errorLabel])
        container.axis = .vertical
        container.spacing = 4
        container.translatesAutoresizingMaskIntoConstraints = false

        let clearWidthConstraint = clearButton.widthAnchor.constraint(equalToConstant: 18)
        let clearHeightConstraint = clearButton.heightAnchor.constraint(equalToConstant: 18)
        rowHeightConstraint = rowView.heightAnchor.constraint(equalToConstant: 44)
        iconWidthConstraint = leadingIcon.widthAnchor.constraint(equalToConstant: 18)
        iconHeightConstraint = leadingIcon.heightAnchor.constraint(equalToConstant: 18)

        super.init(frame: frame)
        addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            row.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            row.topAnchor.constraint(equalTo: rowView.topAnchor),
            row.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
            rowHeightConstraint,
            iconWidthConstraint,
            iconHeightConstraint,
            clearWidthConstraint,
            clearHeightConstraint,
        ])

        field.addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
        field.addTarget(self, action: #selector(handleEditingDidBegin), for: .editingDidBegin)
        field.addTarget(self, action: #selector(handleEditingDidEnd), for: .editingDidEnd)
        field.addTarget(self, action: #selector(handlePrimaryAction), for: .primaryActionTriggered)
        field.addTarget(self, action: #selector(handlePrimaryAction), for: .editingDidEndOnExit)
        field.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleClearTap))
        clearButton.addGestureRecognizer(tap)

        applyType()
        applyStyle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            unsubscribe = ThemeStore.shared.subscribe { [weak self] _ in
                self?.applyStyle()
            }
        } else {
            unsubscribe?()
            unsubscribe = nil
        }
    }

    private func applyType() {
        switch type {
        case .text:
            field.isSecureTextEntry = false
            field.returnKeyType = .done
        case .password:
            field.isSecureTextEntry = true
            field.returnKeyType = .done
        case .textarea:
            field.isSecureTextEntry = false
            field.returnKeyType = .default
        }
    }

    private func applyClearState() {
        clearButton.isHidden = !(isClearable && isFieldFocused && !text.isEmpty)
    }

    private func applyStyle() {
        let theme = ThemeStore.shared.theme
        let hasError = !(error?.isEmpty ?? true)

        let strokeColor: UIColor
        if hasError {
            strokeColor = theme.danger
        } else if isFieldFocused {
            strokeColor = theme.accent
        } else {
            strokeColor = theme.border
        }
        let strokeWidth: CGFloat
        if hasError || isFieldFocused {
            strokeWidth = 1
        } else if variant == .outlined {
            strokeWidth = 1
        } else {
            strokeWidth = 0
        }

        rowView.backgroundColor = variant == .filled ? theme.bgSurfaceSecondary : theme.bgSurface
        rowView.layer.borderWidth = strokeWidth
        rowView.layer.borderColor = strokeColor.cgColor
        rowHeightConstraint.constant = size.heightPt

        field.font = .systemFont(ofSize: size.fontSize)
        field.textColor = theme.fgPrimary
        field.setPlaceholderTextColor(theme.fgTertiary)

        leadingIcon.setImageTint(theme.fgSecondary)
        clearButton.setImageTint(theme.fgTertiary)
        iconWidthConstraint.constant = size.iconPt
        iconHeightConstraint.constant = size.iconPt

        if hasError {
            errorLabel.isHidden = false
            errorLabel.text = error
            errorLabel.textColor = theme.danger
        } else {
            errorLabel.isHidden = true
        }
    }

    @objc private func handleEditingChanged() {
        if maxLength > 0, let current = field.text, current.count > maxLength {
            field.text = String(current.prefix(maxLength))
        }
        onTextChanged?(field.text ?? "")
        applyClearState()
    }

    @objc private func handleEditingDidBegin() {
        isFieldFocused = true
        applyStyle()
        applyClearState()
        onFocusChange?(true)
    }

    @objc private func handleEditingDidEnd() {
        isFieldFocused = false
        applyStyle()
        applyClearState()
        onFocusChange?(false)
    }

    @objc private func handlePrimaryAction() {
        onSubmit?()
    }

    @objc private func handleClearTap() {
        field.text = ""
        onTextChanged?("")
        applyClearState()
        field.becomeFirstResponder()
    }
}

extension RoomInput: UITextFieldDelegate {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard maxLength > 0, let current = textField.text else { return true }
        let candidate = (current as NSString).replacingCharacters(in: range, with: string)
        return candidate.count <= maxLength
    }
}

private extension UITextField {
    func setPlaceholderTextColor(_ color: UIColor) {
        guard let currentPlaceholder = placeholder else { return }
        attributedPlaceholder = NSAttributedString(
            string: currentPlaceholder,
            attributes: [.foregroundColor: color]
        )
    }

    func setCursor(position offset: Int) {
        guard let startPosition = self.position(from: beginningOfDocument, offset: offset) else { return }
        selectedTextRange = textRange(from: startPosition, to: startPosition)
    }
}
