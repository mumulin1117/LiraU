import UIKit

final class LirauOnboardingFlowLorauaWelcomeViewController: UIViewController {
    var onAuthenticated: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let agreementButton = LirauUserAgreementLorauaButton()
    private var keyboardObservers: [NSObjectProtocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LirauUserInterfaceLorauaTheme.darkModeLorauaBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        setupKeyboardHandling()
        updateAgreementState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !LirauOnboardingFlowLorauaStore.shared.hasAgreedUserAgreementLoraua {
            showEULA()
        }
    }

    deinit {
        keyboardObservers.forEach(NotificationCenter.default.removeObserver)
    }

    private func setupLayout() {
        let backdropView = LirauOnboardingFlowLorauaBackdropView(imageName: "lira_auth_bg_books")
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

        let loginButton = LirauInteractiveLearningLorauaButton(title: "Log In")
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(openLogin), for: .touchUpInside)
        contentView.addSubview(loginButton)

        let registerButton = UIButton(type: .system)
        registerButton.setTitle("Sign up", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = LirauUserInterfaceLorauaTheme.interactiveLearningLorauaButtonFont()
        registerButton.layer.cornerRadius = 18
        if let image = UIImage(named: "lira_auth_secondary_button_bg") {
            registerButton.setBackgroundImage(
                image.resizableImage(withCapInsets: UIEdgeInsets(top: 18, left: 24, bottom: 18, right: 24)),
                for: .normal
            )
        } else {
            registerButton.layer.borderWidth = 1
            registerButton.layer.borderColor = LirauUserInterfaceLorauaTheme.interactiveLearningLorauaPrimary.cgColor
        }
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        registerButton.addTarget(self, action: #selector(openRegister), for: .touchUpInside)
        contentView.addSubview(registerButton)

        let appleButton = UIButton(type: .system)
        appleButton.setImage(UIImage(named: "lira_auth_apple_mark")?.withRenderingMode(.alwaysOriginal), for: .normal)
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(appleButton)

        let termsStack = LirauDataPrivacyLorauaLinksView()
        termsStack.translatesAutoresizingMaskIntoConstraints = false
        termsStack.onPrivacyTapped = { [weak self] in
            self?.openPrivacy()
        }
        termsStack.onTermsTapped = { [weak self] in
            self?.openTerms()
        }
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

    private func updateAgreementState() {
        agreementButton.isAgreed = LirauOnboardingFlowLorauaStore.shared.hasAgreedUserAgreementLoraua
    }

    @objc private func toggleAgreement() {
        LirauOnboardingFlowLorauaStore.shared.hasAgreedUserAgreementLoraua.toggle()
        updateAgreementState()
    }

    @objc private func openLogin() {
        guard LirauOnboardingFlowLorauaStore.shared.hasAgreedUserAgreementLoraua else {
            showEULA()
            return
        }
        let controller = LirauIdentityVerificationLorauaLoginViewController()
        controller.onAuthenticated = onAuthenticated
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func openRegister() {
        guard LirauOnboardingFlowLorauaStore.shared.hasAgreedUserAgreementLoraua else {
            showEULA()
            return
        }
        let controller = LirauOnboardingFlowLorauaRegisterViewController()
        controller.onAuthenticated = onAuthenticated
        navigationController?.pushViewController(controller, animated: true)
    }

    private func openPrivacy() {
        openLegalWebPath(LirauDeepLinkingLorauaRoute.privacyPolicyLorauaPath())
    }

    private func openTerms() {
        openLegalWebPath(LirauDeepLinkingLorauaRoute.userAgreementLorauaPath())
    }

    private func openLegalWebPath(_ path: String) {
        let controller = LirauDeepLinkingLorauaPortalViewController(deepLinkingLorauaEntryURLString: path)
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showEULA() {
        let message = """
        Effective Date: June 1, 2026

        Contact Email: liraU@gmail.com

        This End User License Agreement ("Agreement") is a binding legal contract between you and LiraU. By installing, accessing, or using the LiraU mobile application ("Application"), you agree to be bound by the terms of this Agreement. LiraU grants you a personal, revocable, non-exclusive, non-transferable, and limited license to download, install, and use the Application strictly for your personal, non-commercial entertainment and language learning purposes on a compatible mobile device.

        User Behavior Restrictions
        LiraU is an innovative social ecosystem dedicated to global friendship and linguistic exploration. To preserve this harmonious environment, your behavioral conduct must remain exemplary. You are strictly prohibited from utilizing the Application to:

        Engage in, facilitate, or promote any form of harassment, hate speech, discrimination, or verbal abuse targeted at regional accents, cultural traditions, or national origins.

        Transmit, broadcast, or upload any obscene, profane, defamatory, or sexually explicit content via audio streaming, video snippets, or  video calls.

        Deploy automated systems, including data-scraping bots or artificial voice synthesizers, to manipulate language matches, spoof real-time translations, or harvest user data.

        Disrupt the interactive speech mechanisms or deliberately degrade the audio quality of community chatrooms through sonic interference or malicious reporting.

        Impersonate any native speakers, language mentors, or LiraU representatives to defraud or mislead users regarding cultural backgrounds.

        Termination of License
        LiraU reserves the absolute, unilateral right to monitor user content and terminate or suspend your license and access to the Application immediately, without prior notice or liability, for any reason whatsoever. Reasons for termination include, but are not limited to, a breach of any user behavior restrictions outlined above, a formal community report indicating cultural intolerance, or a violation of local laws. Upon termination, your right to use the Application will cease instantly. You must immediately delete all copies of the Application from your devices. LiraU is not responsible for any loss of conversational history, cross-cultural connections, or virtual milestones resulting from license termination.
        """
        let alert = UIAlertController(title: "LiraU End User License Agreement (EULA)", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Agree", style: .default) { _ in
            LirauOnboardingFlowLorauaStore.shared.hasAgreedUserAgreementLoraua = true
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
