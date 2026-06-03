import UIKit

final class LirauRegisterViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var onAuthenticated: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let emailField = LirauTextField(placeholder: "Enter email address", iconName: "lira_auth_email_icon")
    private let passwordField = LirauTextField(placeholder: "Enter password", isSecure: true, iconName: "lira_auth_password_icon")
    private weak var activeField: UITextField?
    private var keyboardObservers: [NSObjectProtocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LirauTheme.background
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

        let backdropView = LirauAuthBackdropView(imageName: "lira_auth_bg_books")
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

        let titleMarkView = UIImageView(image: UIImage(named: "lira_sign_title_mark"))
        titleMarkView.contentMode = .scaleAspectFit
        titleMarkView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleMarkView)

        emailField.keyboardType = .emailAddress
        emailField.textContentType = .username
        emailField.delegate = self
        emailField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailField)

        passwordField.textContentType = .newPassword
        passwordField.delegate = self
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordField)

        let nextButton = LirauPrimaryButton(title: "Next")
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(continueToProfile), for: .touchUpInside)
        contentView.addSubview(nextButton)

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

            titleMarkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 39),
            titleMarkView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 284),
            titleMarkView.widthAnchor.constraint(equalToConstant: 130),
            titleMarkView.heightAnchor.constraint(equalToConstant: 70),

       
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 21),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -21),
            emailField.topAnchor.constraint(equalTo: titleMarkView.bottomAnchor, constant: 18),

            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 14),

            nextButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            nextButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            nextButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }

    @objc private func close() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func continueToProfile() {
        view.endEditing(true)
        let password = passwordField.text ?? ""
        switch LirauAuthStore.shared.canRegister(email: emailField.text ?? "", password: password) {
        case .success(let email):
            let controller = LirauProfileSetupViewController(email: email, password: password)
            controller.onAuthenticated = onAuthenticated
            navigationController?.pushViewController(controller, animated: true)
        case .failure(let error):
            lirauShowAlert(title: "Registration failed", message: error.message)
        }
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
