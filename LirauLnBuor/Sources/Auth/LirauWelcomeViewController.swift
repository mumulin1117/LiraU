import UIKit

final class LirauWelcomeViewController: UIViewController {
    var onAuthenticated: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let agreementButton = LirauAgreementButton()
    private var keyboardObservers: [NSObjectProtocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LirauTheme.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        setupKeyboardHandling()
        updateAgreementState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !LirauAuthStore.shared.hasAgreedEULA {
            showEULA()
        }
    }

    deinit {
        keyboardObservers.forEach(NotificationCenter.default.removeObserver)
    }

    private func setupLayout() {
        let backdropView = LirauAuthBackdropView(imageName: "lira_auth_bg_books")
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdropView)

        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let logoView = UIImageView(image: UIImage(named: "lira_logo_chat"))
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoView)

        let appNameLabel = UILabel()
        appNameLabel.text = "LiraU"
        appNameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        appNameLabel.textColor = .white
        appNameLabel.textAlignment = .center
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(appNameLabel)

        let loginButton = LirauPrimaryButton(title: "Log In")
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(openLogin), for: .touchUpInside)
        contentView.addSubview(loginButton)

        let registerButton = UIButton(type: .system)
        registerButton.setTitle("Sign up", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = LirauTheme.buttonFont()
        registerButton.layer.cornerRadius = 18
        if let image = UIImage(named: "lira_auth_secondary_button_bg") {
            registerButton.setBackgroundImage(
                image.resizableImage(withCapInsets: UIEdgeInsets(top: 18, left: 24, bottom: 18, right: 24)),
                for: .normal
            )
        } else {
            registerButton.layer.borderWidth = 1
            registerButton.layer.borderColor = LirauTheme.primary.cgColor
        }
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        registerButton.addTarget(self, action: #selector(openRegister), for: .touchUpInside)
        contentView.addSubview(registerButton)

        let appleButton = UIButton(type: .system)
        appleButton.setImage(UIImage(named: "lira_auth_apple_mark")?.withRenderingMode(.alwaysOriginal), for: .normal)
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(appleButton)

        let termsStack = UIStackView()
        termsStack.axis = .horizontal
        termsStack.alignment = .center
        termsStack.spacing = 6
        termsStack.translatesAutoresizingMaskIntoConstraints = false

        let privacyButton = makeLinkButton(title: "Privacy Policy", action: #selector(openPrivacy))
        let separatorLabel = UILabel()
        separatorLabel.text = "and"
        separatorLabel.font = .systemFont(ofSize: 10)
        separatorLabel.textColor = LirauTheme.mutedText
        let termsButton = makeLinkButton(title: "Terms of Service", action: #selector(openTerms))
        termsStack.addArrangedSubview(privacyButton)
        termsStack.addArrangedSubview(separatorLabel)
        termsStack.addArrangedSubview(termsButton)
        contentView.addSubview(termsStack)

        agreementButton.translatesAutoresizingMaskIntoConstraints = false
        agreementButton.addTarget(self, action: #selector(toggleAgreement), for: .touchUpInside)
        contentView.addSubview(agreementButton)

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            logoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoView.topAnchor.constraint(greaterThanOrEqualTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 190),
            logoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -42),
            logoView.widthAnchor.constraint(equalToConstant: 90),
            logoView.heightAnchor.constraint(equalToConstant: 90),

            appNameLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 8),
            appNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            loginButton.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 26),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 21),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -21),

            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            registerButton.leadingAnchor.constraint(equalTo: loginButton.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor),

            appleButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 23),
            appleButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            appleButton.widthAnchor.constraint(equalToConstant: 48),
            appleButton.heightAnchor.constraint(equalToConstant: 48),

            agreementButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            agreementButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            agreementButton.bottomAnchor.constraint(equalTo: termsStack.topAnchor, constant: -4),

            termsStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            termsStack.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }

    private func makeLinkButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.72), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func updateAgreementState() {
        agreementButton.isAgreed = LirauAuthStore.shared.hasAgreedEULA
    }

    @objc private func toggleAgreement() {
        LirauAuthStore.shared.hasAgreedEULA.toggle()
        updateAgreementState()
    }

    @objc private func openLogin() {
        guard LirauAuthStore.shared.hasAgreedEULA else {
            showEULA()
            return
        }
        let controller = LirauLoginViewController()
        controller.onAuthenticated = onAuthenticated
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func openRegister() {
        guard LirauAuthStore.shared.hasAgreedEULA else {
            showEULA()
            return
        }
        let controller = LirauRegisterViewController()
        controller.onAuthenticated = onAuthenticated
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func openPrivacy() {
        navigationController?.pushViewController(LirauTermsViewController(kind: .privacy), animated: true)
    }

    @objc private func openTerms() {
        navigationController?.pushViewController(LirauTermsViewController(kind: .terms), animated: true)
    }

    private func showEULA() {
        let message = """
        This service is not a random, anonymous, adult, or suggestive chat service.

        Users must follow community conduct rules, meet account registration requirements, respect age and local identity laws, use report and block tools when needed, and accept strict content review and penalties for violations.
        """
        let alert = UIAlertController(title: "LiraU EULA", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Agree", style: .default) { _ in
            LirauAuthStore.shared.hasAgreedEULA = true
            self.updateAgreementState()
        })
        present(alert, animated: true)
    }

    private func setupKeyboardHandling() {
        let center = NotificationCenter.default
        keyboardObservers.append(center.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateKeyboardInset(notification: notification, isShowing: true)
        })
        keyboardObservers.append(center.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateKeyboardInset(notification: notification, isShowing: false)
        })
    }

    private func updateKeyboardInset(notification: Notification, isShowing: Bool) {
        let height: CGFloat
        if isShowing,
           let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            height = view.convert(frame, from: nil).intersection(view.bounds).height
        } else {
            height = 0
        }
        let inset = isShowing ? height + 16 : 0
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset
    }
}
