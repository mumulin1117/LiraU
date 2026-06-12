import UIKit

final class LirauInteractiveLearningLorauaButton: UIButton {
    private let gradientLayer = CAGradientLayer()

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = LirauUserInterfaceLorauaTheme.interactiveLearningLorauaButtonFont()
        layer.cornerRadius = 18
        layer.masksToBounds = true
        if let image = UIImage(named: "lira_auth_primary_button_bg") {
            setBackgroundImage(image.resizableImage(withCapInsets: UIEdgeInsets(top: 18, left: 24, bottom: 18, right: 24)), for: .normal)
        } else {
            gradientLayer.colors = [LirauUserInterfaceLorauaTheme.interactiveLearningLorauaPrimary.cgColor, LirauUserInterfaceLorauaTheme.interactiveLearningLorauaPrimaryEnd.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            layer.insertSublayer(gradientLayer, at: 0)
        }
        heightAnchor.constraint(equalToConstant: 52).isActive = true
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
}

final class LirauDialogueFlowLorauaTextField: UITextField {
    init(placeholder: String, isSecure: Bool = false, iconName: String? = nil) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecure
        autocorrectionType = .no
        autocapitalizationType = .none
        borderStyle = .none
        font = LirauUserInterfaceLorauaTheme.readingComprehensionLorauaBodyFont(14)
        textColor = .white
        tintColor = .white
        backgroundColor = LirauUserInterfaceLorauaTheme.onboardingFlowLorauaAuthField
        layer.cornerRadius = 18
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(white: 1.0, alpha: 0.62)]
        )
        if let iconName {
          
            leftView = makeIconPaddingView(iconName: iconName)
        } else {
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 1))
        }
        leftViewMode = .always
        heightAnchor.constraint(equalToConstant: 46).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeIconPaddingView(iconName: String) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        let imageView = UIImageView(image: UIImage(named: iconName))
        imageView.contentMode = .scaleAspectFit
        
        imageView.frame = CGRect(x: 10, y: 0, width: 30, height:30)
        container.addSubview(imageView)
        return container
    }
}

final class LirauCulturalExchangeLorauaInfoCardView: UIView {
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    init(title: String, body: String) {
        super.init(frame: .zero)
        backgroundColor = LirauUserInterfaceLorauaTheme.userExperienceLorauaCard
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = LirauUserInterfaceLorauaTheme.visualCuesLorauaBorder.cgColor

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = LirauUserInterfaceLorauaTheme.linguisticsLorauaText
        titleLabel.numberOfLines = 0

        bodyLabel.text = body
        bodyLabel.font = LirauUserInterfaceLorauaTheme.readingComprehensionLorauaBodyFont(14)
        bodyLabel.textColor = LirauUserInterfaceLorauaTheme.languageAcquisitionLorauaSecondaryText
        bodyLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 16),
            bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 16)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    func lirauAlertSoundLorauaNotice(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

final class LirauOnboardingFlowLorauaBackdropView: UIView {
    private let imageView: UIImageView
    private let overlayView = UIView()

    init(imageName: String) {
        imageView = UIImageView(image: UIImage(named: imageName))
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class LirauUserAgreementLorauaButton: UIButton {
    var isAgreed: Bool = false {
        didSet { updateImage() }
    }

    init() {
        super.init(frame: .zero)
        setTitle("  I have read and agree to Privacy Policy and Terms.", for: .normal)
        setTitleColor(LirauUserInterfaceLorauaTheme.verbalNuanceLorauaMutedText, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 11, weight: .regular)
        titleLabel?.numberOfLines = 2
        contentHorizontalAlignment = .leading
        updateImage()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateImage() {
        let name = isAgreed ? "lira_auth_agreement_checked" : "lira_auth_agreement_unchecked"
        setImage(UIImage(named: name)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
}

final class LirauDataPrivacyLorauaLinksView: UIStackView {
    var onPrivacyTapped: (() -> Void)?
    var onTermsTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = 6

        let privacyButton = makeLinkButton(title: "Privacy Policy") { [weak self] in
            self?.onPrivacyTapped?()
        }
        let separatorLabel = UILabel()
        separatorLabel.text = "and"
        separatorLabel.font = .systemFont(ofSize: 10)
        separatorLabel.textColor = LirauUserInterfaceLorauaTheme.verbalNuanceLorauaMutedText
        let termsButton = makeLinkButton(title: "Terms of Service") { [weak self] in
            self?.onTermsTapped?()
        }

        addArrangedSubview(privacyButton)
        addArrangedSubview(separatorLabel)
        addArrangedSubview(termsButton)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeLinkButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.72), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: .medium)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }
}
