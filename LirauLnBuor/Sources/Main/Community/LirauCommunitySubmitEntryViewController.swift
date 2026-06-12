import UIKit

final class LirauCommunitySubmitEntryViewController: UIViewController {
    var onSubmitted: (() -> Void)?

    private let challengeID: String
    private let store = LirauCommunityLocalStore.shared
    private let backgroundView = LirauCommunityBackgroundView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let inputCard = LirauCommunityEntryInputCard(placeholder: "Hoy me siento como...")
    private let submitButton = LirauCommunityGradientButton(type: .system)
    private var submitButtonBottomConstraint: NSLayoutConstraint?
    private var isSubmitting = false

    init(challengeID: String) {
        self.challengeID = challengeID
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildInterface()
        registerKeyboardObservers()
        validateSubmitAccess()
        updateSubmitState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputCard.focusTextInput()
    }

    private func buildInterface() {
        view.backgroundColor = LirauCommunityPalette.background
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 15
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 120, right: 20)
        contentStack.isLayoutMarginsRelativeArrangement = true
        scrollView.addSubview(contentStack)

        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.gradientColors = [
            LirauCommunityPalette.green,
            UIColor(red: 0.16, green: 0.82, blue: 0.72, alpha: 1)
        ]
        submitButton.addTarget(self, action: #selector(submitEntry), for: .touchUpInside)
        view.addSubview(submitButton)

        contentStack.addArrangedSubview(makeSubmitHeader())
        contentStack.addArrangedSubview(
            LirauCommunityCreateInfoCard(
                systemName: "pencil.and.scribble",
                title: "Your entry",
                subtitle: "Write one sentence answering the host's prompt."
            )
        )
        contentStack.addArrangedSubview(makePromptCard())
        contentStack.addArrangedSubview(inputCard)
        contentStack.addArrangedSubview(makeHeadsUpCard())
        contentStack.addArrangedSubview(makeVisibilityLabel())

        inputCard.onTextChanged = { [weak self] _ in
            self?.updateSubmitState()
        }

        submitButtonBottomConstraint = submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            submitButtonBottomConstraint!,
            submitButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func makeSubmitHeader() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let closeButton = LirauCommunityIconButton(systemName: "chevron.left")
        closeButton.addTarget(self, action: #selector(closePage), for: .touchUpInside)

        let label = UILabel()
        label.text = "Submit Entry"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)

        row.addArrangedSubview(closeButton)
        row.addArrangedSubview(label)
        row.addArrangedSubview(UIView())

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        return row
    }

    private func makePromptCard() -> UIView {
        let challenge = store.challenge(with: challengeID)
        let card = UIView()
        card.applyLirauCommunityChrome(
            backgroundColor: LirauCommunityPalette.elevated.withAlphaComponent(0.82),
            cornerRadius: 18,
            borderAlpha: 0.08,
            shadowAlpha: 0.07
        )

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = LirauCommunityPalette.mutedText
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.text = challenge.map { "\($0.title)\n\($0.prompt)" } ?? "Write one sentence for this LiraU challenge."
        card.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    private func makeHeadsUpCard() -> UIView {
        let wrapper = UIView()
        wrapper.applyLirauCommunityChrome(
            backgroundColor: UIColor(red: 0.18, green: 0.15, blue: 0.25, alpha: 0.94),
            cornerRadius: 16,
            borderAlpha: 0.1,
            shadowAlpha: 0.05
        )

        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = LirauCommunityPalette.yellow
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Once submitted, you become a participant. You can't switch to vote-only, and can't vote for your own entry."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = LirauCommunityPalette.mutedText

        wrapper.addSubview(icon)
        wrapper.addSubview(label)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 14),
            icon.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 14),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),

            label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 13),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -13)
        ])
        return wrapper
    }

    private func makeVisibilityLabel() -> UIView {
        let label = UILabel()
        label.text = "Visible to \(visibleVoterCount()) voters"
        label.textColor = LirauCommunityPalette.dimText
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 1
        return label
    }

    private func visibleVoterCount() -> Int {
        guard let challenge = store.challenge(with: challengeID) else { return 1 }
        let count = challenge.joinedCount + challenge.totalVoteCount + challenge.entries.count
        return min(128, max(1, count))
    }

    private func validateSubmitAccess() {
        guard let challenge = store.challenge(with: challengeID) else {
            showToast("Challenge was not found.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }

        guard challenge.phase == .open, challenge.currentUserMode == .none else {
            showToast(submitBlockedMessage(for: challenge))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }
    }

    private func submitBlockedMessage(for challenge: LirauCommunityChallenge) -> String {
        if challenge.currentUserMode == .host {
            return "Hosts can view entries but can't submit or vote."
        }
        if challenge.currentUserMode == .submitted {
            return "You've already joined this challenge."
        }
        if challenge.currentUserMode == .voteOnly {
            return "You already chose vote-only mode."
        }
        if challenge.phase == .voting {
            return "Submissions closed."
        }
        if challenge.phase == .ended {
            return "This challenge has ended."
        }
        return "This challenge is not accepting entries."
    }

    private func updateSubmitState() {
        let canSubmit = !inputCard.sentence.isEmpty && !isSubmitting
        submitButton.isEnabled = canSubmit
        submitButton.alpha = canSubmit ? 1 : 0.45
    }

    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let converted = view.convert(frame, from: nil)
        let overlap = max(0, view.bounds.maxY - converted.minY)
        let inset = overlap + 104
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
        submitButtonBottomConstraint?.constant = -(overlap + 14)
        UIView.animate(withDuration: 0.22) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 90
        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        submitButtonBottomConstraint?.constant = -14
        UIView.animate(withDuration: 0.22) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }

    @objc private func closePage() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func submitEntry() {
        guard !isSubmitting else { return }
        let sentence = inputCard.sentence
        guard !sentence.isEmpty else {
            showToast("Write a sentence before submitting.")
            return
        }

        isSubmitting = true
        updateSubmitState()
        view.endEditing(true)

        switch store.joinChallengeWithEntry(challengeID: challengeID, sentence: sentence) {
        case .success:
            NSLog("LiraU Community submit entry: %@", challengeID)
            onSubmitted?()
            presentSubmittedModal(entryText: sentence)
        case .failure(let error):
            isSubmitting = false
            updateSubmitState()
            showToast(error.localizedDescription)
        }
    }

    private func presentSubmittedModal(entryText: String) {
        let modal = LirauCommunityEntrySubmittedModalViewController(entryText: entryText)
        modal.onViewChallenge = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        present(modal, animated: true)
    }
}
