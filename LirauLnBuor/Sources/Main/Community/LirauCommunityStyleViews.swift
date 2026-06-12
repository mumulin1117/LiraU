import UIKit

enum LirauCommunityPalette {
    static let background = UIColor(red: 0.064, green: 0.057, blue: 0.122, alpha: 1)
    static let surface = UIColor(red: 0.106, green: 0.091, blue: 0.178, alpha: 1)
    static let card = UIColor(red: 0.126, green: 0.107, blue: 0.207, alpha: 1)
    static let elevated = UIColor(red: 0.17, green: 0.139, blue: 0.284, alpha: 1)
    static let purple = UIColor(red: 0.49, green: 0.22, blue: 1.0, alpha: 1)
    static let purpleLight = UIColor(red: 0.79, green: 0.27, blue: 1.0, alpha: 1)
    static let purpleSoft = UIColor(red: 0.62, green: 0.36, blue: 1.0, alpha: 1)
    static let text = UIColor.white
    static let mutedText = UIColor(red: 0.72, green: 0.68, blue: 0.84, alpha: 1)
    static let dimText = UIColor(red: 0.55, green: 0.51, blue: 0.67, alpha: 1)
    static let green = UIColor(red: 0.25, green: 0.91, blue: 0.55, alpha: 1)
    static let yellow = UIColor(red: 1.0, green: 0.72, blue: 0.25, alpha: 1)
}

enum LirauCommunityFormatter {
    static func compact(_ value: Int) -> String {
        if value >= 1000 {
            let number = Double(value) / 1000.0
            return String(format: "%.1fk votes", number)
        }
        return "\(value) votes"
    }

    static func relativeTime(_ date: Date) -> String {
        let seconds = max(0, Int(Date().timeIntervalSince(date)))
        if seconds < 3600 {
            return "\(max(1, seconds / 60))m ago"
        }
        if seconds < 86_400 {
            return "\(seconds / 3600)h ago"
        }
        return "\(seconds / 86_400)d ago"
    }
}

final class LirauCommunityBackgroundView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [
            UIColor(red: 0.75, green: 0.23, blue: 1.0, alpha: 0.96).cgColor,
            UIColor(red: 0.35, green: 0.17, blue: 0.78, alpha: 0.72).cgColor,
            LirauCommunityPalette.background.cgColor
        ]
        gradientLayer.locations = [0, 0.2, 0.52]
        layer.addSublayer(gradientLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

final class LirauCommunityGradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    var gradientColors: [UIColor] = [LirauCommunityPalette.purpleLight, LirauCommunityPalette.purple] {
        didSet { updateGradientColors() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = 20
        clipsToBounds = true
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14.5, weight: .bold)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        updateGradientColors()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }

    private func updateGradientColors() {
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }
}

final class LirauCommunityFilterTabsView: UIView {
    var onFilterChanged: ((LirauCommunityFilter) -> Void)?
    private var selectedFilter: LirauCommunityFilter = .all
    private var buttons: [LirauCommunityFilter: UIButton] = [:]
    private var underlines: [LirauCommunityFilter: UIView] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildTabs()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelectedFilter(_ filter: LirauCommunityFilter) {
        selectedFilter = filter
        updateButtonStates()
    }

    private func buildTabs() {
        translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 24
        addSubview(stack)

        LirauCommunityFilter.allCases.forEach { filter in
            let wrapper = UIStackView()
            wrapper.axis = .vertical
            wrapper.alignment = .center
            wrapper.spacing = 4

            let button = UIButton(type: .system)
            button.setTitle(filter.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            button.tag = LirauCommunityFilter.allCases.firstIndex(of: filter) ?? 0
            button.backgroundColor = .clear
            button.addTarget(self, action: #selector(selectFilter(_:)), for: .touchUpInside)
            buttons[filter] = button
            wrapper.addArrangedSubview(button)

            let underline = UIView()
            underline.translatesAutoresizingMaskIntoConstraints = false
            underline.layer.cornerRadius = 2
            underlines[filter] = underline
            wrapper.addArrangedSubview(underline)

            stack.addArrangedSubview(wrapper)
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 30),
                button.widthAnchor.constraint(greaterThanOrEqualToConstant: 48),
                underline.widthAnchor.constraint(equalToConstant: 34),
                underline.heightAnchor.constraint(equalToConstant: 4)
            ])
        }
        stack.addArrangedSubview(UIView())

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 40),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        updateButtonStates()
    }

    @objc private func selectFilter(_ sender: UIButton) {
        let filters = LirauCommunityFilter.allCases
        guard sender.tag < filters.count else { return }
        selectedFilter = filters[sender.tag]
        updateButtonStates()
        onFilterChanged?(selectedFilter)
    }

    private func updateButtonStates() {
        buttons.forEach { filter, button in
            let isSelected = filter == selectedFilter
            button.backgroundColor = .clear
            button.setTitleColor(isSelected ? LirauCommunityPalette.purpleLight : LirauCommunityPalette.mutedText, for: .normal)
            underlines[filter]?.backgroundColor = isSelected ? LirauCommunityPalette.purpleLight : .clear
        }
    }
}

final class LirauCommunityStatusPill: UILabel {
    init(status: LirauCommunityChallengeStatus) {
        super.init(frame: .zero)
        textAlignment = .center
        font = .systemFont(ofSize: 11, weight: .bold)
        layer.cornerRadius = 11
        layer.borderWidth = 1
        clipsToBounds = true
        setStatus(status)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setStatus(_ status: LirauCommunityChallengeStatus) {
        text = status.title
        switch status {
        case .live:
            textColor = LirauCommunityPalette.green
            backgroundColor = LirauCommunityPalette.green.withAlphaComponent(0.18)
            layer.borderColor = LirauCommunityPalette.green.withAlphaComponent(0.2).cgColor
        case .voting:
            textColor = LirauCommunityPalette.yellow
            backgroundColor = LirauCommunityPalette.yellow.withAlphaComponent(0.16)
            layer.borderColor = LirauCommunityPalette.yellow.withAlphaComponent(0.22).cgColor
        case .ended:
            textColor = LirauCommunityPalette.mutedText
            backgroundColor = UIColor.white.withAlphaComponent(0.09)
            layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        }
    }
}



final class LirauCommunityIconButton: UIButton {
    init(systemName: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 18
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tintColor = .white
        setImage(UIImage(systemName: systemName), for: .normal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class LirauCommunityEmptyStateView: UIView {
    init(message: String) {
        super.init(frame: .zero)
        backgroundColor = LirauCommunityPalette.card.withAlphaComponent(0.88)
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        let iconView = UIImageView(image: UIImage(systemName: "sparkles"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = LirauCommunityPalette.purpleLight
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.textColor = LirauCommunityPalette.mutedText
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        addSubview(label)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    func showToast(_ message: String) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.78)
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 28),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -28),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])
        label.alpha = 0
        UIView.animate(withDuration: 0.18) {
            label.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.24, delay: 1.35, options: []) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
    }

    func presentShareSheet(items: [Any]) {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = controller.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(controller, animated: true)
    }

    func showReportNotice(target: String) {
        let alert = UIAlertController(
            title: "Report",
            message: "Report \(target) for community review?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
            NSLog("LiraU Community report: %@", target)
            self?.showToast("Report received.")
        })
        present(alert, animated: true)
    }
}

extension UIView {
    func applyLirauCommunityChrome(
        backgroundColor: UIColor = LirauCommunityPalette.card,
        cornerRadius: CGFloat = 20,
        borderAlpha: CGFloat = 0.08,
        shadowAlpha: Float = 0.18
    ) {
        self.backgroundColor = backgroundColor
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(borderAlpha).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowAlpha
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)
    }
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { view in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

extension UIColor {
    convenience init(lirauHex: String) {
        let value = lirauHex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: value).scanHexInt64(&rgb)
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: 1
        )
    }
}
