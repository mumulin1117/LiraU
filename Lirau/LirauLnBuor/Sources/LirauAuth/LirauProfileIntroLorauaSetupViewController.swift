import UIKit

final class LirauProfileIntroLorauaSetupViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var onAuthenticated: (() -> Void)?

    private let email: String
    private let password: String
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let nameField = LirauDialogueFlowLorauaTextField(placeholder: "Enter your name")
    private let introField = LirauDialogueFlowLorauaTextField(placeholder: "Say something")
    private let finishButton = LirauInteractiveLearningLorauaButton(title: "Sign Up")
    private weak var activeField: UITextField?
    private var keyboardObservers: [NSObjectProtocol] = []

    init(email: String, password: String) {
        self.email = email
        self.password = password
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LirauUserInterfaceLorauaTheme.darkModeLorauaBackground
        setupLayout()
        setupKeyboardHandling()
    }

    deinit {
        keyboardObservers.forEach(NotificationCenter.default.removeObserver)
    }

    private func setupLayout() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        let backdropView = LirauOnboardingFlowLorauaBackdropView(imageName: "lira_auth_bg_books")
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdropView)

        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(named: "lira_auth_close_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        contentView.addSubview(closeButton)

        let avatarButton = UIButton(type: .system)
        avatarButton.setImage(UIImage(named: "lira_auth_avatar_add_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        avatarButton.backgroundColor = LirauUserInterfaceLorauaTheme.userExperienceLorauaCard
        avatarButton.layer.cornerRadius = 33
        avatarButton.clipsToBounds = true
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarButton)

        nameField.delegate = self
        nameField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameField)

        introField.delegate = self
        introField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(introField)

        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.addTarget(self, action: #selector(finishRegistration), for: .touchUpInside)
        contentView.addSubview(finishButton)

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

            closeButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 18),
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            avatarButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 222),
            avatarButton.widthAnchor.constraint(equalToConstant: 66),
            avatarButton.heightAnchor.constraint(equalToConstant: 66),

            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 21),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -21),
            nameField.topAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: 70),

            introField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            introField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            introField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 14),

            finishButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            finishButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            finishButton.topAnchor.constraint(equalTo: introField.bottomAnchor, constant: 24),
            finishButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }

    @objc private func close() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func finishRegistration() {
        view.endEditing(true)
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let intro = introField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        let profile = LirauGlobalCitizenLorauaAccountProfile(
            globalCitizenLorauaID: UUID().uuidString,
            pointSystemLorauaToken: password,
            emailMarketingLorauaAddress: email,
            nativeSpeakerLorauaName: name?.isEmpty == false ? name! : "LiraU Learner",
            profileIntroLorauaBio: intro?.isEmpty == false ? intro! : "Ready to share everyday language and culture.",
            languagePairingLorauaSummary: "English - Global culture"
        )
        setSubmitting(true)
        LirauOnboardingFlowLorauaStore.shared.onboardingFlowLorauaRegister(profile: profile, password: password) { [weak self] result in
            guard let self else { return }
            self.setSubmitting(false)
            switch result {
            case .success:
                self.onAuthenticated?()
            case .failure(let error):
                self.lirauAlertSoundLorauaNotice(title: "Registration failed", message: error.message)
            }
        }
    }

    private func setSubmitting(_ submitting: Bool) {
        finishButton.isEnabled = !submitting
        finishButton.alpha = submitting ? 0.65 : 1
    }

    private func setupKeyboardHandling() {
        let center = NotificationCenter.default
        keyboardObservers.append(center.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] note in
            self?.setKeyboardInset(note, showing: true)
        })
        keyboardObservers.append(center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] note in
            self?.setKeyboardInset(note, showing: false)
        })
    }

    private func setKeyboardInset(_ notification: Notification, showing: Bool) {
        let height: CGFloat
        if showing,
           let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            height = view.convert(frame, from: nil).intersection(view.bounds).height
        } else {
            height = 0
        }
        let inset = showing ? height + 16 : 0
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset
        if showing, let activeField {
            scrollView.scrollRectToVisible(activeField.convert(activeField.bounds, to: scrollView).insetBy(dx: 0, dy: -24), animated: true)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if activeField === textField {
            activeField = nil
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var touchedView = touch.view
        while let view = touchedView {
            if view is UIControl || view is UITextField {
                return false
            }
            touchedView = view.superview
        }
        return true
    }
}
