import UIKit

final class LirauCommunityCreateChallengeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var onCreated: ((LirauCommunityChallenge) -> Void)?

    private let store = LirauCommunityLocalStore.shared
    private let backgroundView = LirauCommunityBackgroundView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleField = UITextField()
    private let titleCountLabel = UILabel()
    private let promptTextView = UITextView()
    private let promptPlaceholderLabel = UILabel()
    private let durationSelector = LirauCommunityDurationSelector()
    private let coverPicker = LirauCommunityLocalCoverPicker()
    private let publishButton = LirauCommunityGradientButton(type: .system)

    private let maxTitleLength = 50
    private let maxPromptLength = 140
    private let challengeLanguage = "Spanish"
    private var selectedDuration: LirauCommunityChallengeDurationOption = .standard
    private var selectedCoverAssetName = "lira_community_challenge_cover"
    private var selectedCoverLocalImageURI: String?
    private var isPublishing = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildInterface()
        registerKeyboardObservers()
        updatePublishState()
    }

    private func buildInterface() {
        view.backgroundColor = LirauCommunityPalette.background
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 15
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 18, bottom: 28, right: 18)
        contentStack.isLayoutMarginsRelativeArrangement = true
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(makeHeader())
        contentStack.addArrangedSubview(
            LirauCommunityCreateInfoCard(
                systemName: "person.wave.2.fill",
                title: "Host your own challenge",
                subtitle: "Write a prompt and let the community answer."
            )
        )
        contentStack.addArrangedSubview(makeTitleSection())
        contentStack.addArrangedSubview(makePromptSection())
        contentStack.addArrangedSubview(makeDurationSection())
        contentStack.addArrangedSubview(makeCoverSection())
        contentStack.addArrangedSubview(makeHeadsUpView())
        contentStack.addArrangedSubview(makeVisibilitySection())
        contentStack.addArrangedSubview(makePublishSection())

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

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
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func makeHeader() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let closeButton = LirauCommunityIconButton(systemName: "xmark")
        closeButton.addTarget(self, action: #selector(closePage), for: .touchUpInside)

        let label = UILabel()
        label.text = "Create Challenge"
        label.textColor = .white
        label.font = .systemFont(ofSize: 19, weight: .bold)

        row.addArrangedSubview(closeButton)
        row.addArrangedSubview(label)
        row.addArrangedSubview(UIView())

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        return row
    }

    private func makeTitleSection() -> UIView {
        let card = makeFormCard()
        let stack = makeFormStack(in: card)

        let header = makeSectionHeader(title: "Title", trailing: titleCountLabel)
        configureTitleField()

        let helper = makeHelperLabel("Keep it short and inviting")

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(titleField)
        stack.addArrangedSubview(helper)

        NSLayoutConstraint.activate([
            titleField.heightAnchor.constraint(equalToConstant: 48)
        ])
        return card
    }

    private func makePromptSection() -> UIView {
        let card = makeFormCard()
        let stack = makeFormStack(in: card)

        let header = makeSectionHeader(title: "Prompt", trailing: nil)

        promptTextView.translatesAutoresizingMaskIntoConstraints = false
        promptTextView.delegate = self
        promptTextView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        promptTextView.layer.cornerRadius = 16
        promptTextView.textColor = .white
        promptTextView.font = .systemFont(ofSize: 14, weight: .semibold)
        promptTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)

        promptPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        promptPlaceholderLabel.text = "Invite learners to answer in one sentence."
        promptPlaceholderLabel.textColor = LirauCommunityPalette.dimText
        promptPlaceholderLabel.font = .systemFont(ofSize: 14, weight: .medium)
        promptTextView.addSubview(promptPlaceholderLabel)

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(promptTextView)

        NSLayoutConstraint.activate([
            promptTextView.heightAnchor.constraint(equalToConstant: 96),
            promptPlaceholderLabel.topAnchor.constraint(equalTo: promptTextView.topAnchor, constant: 12),
            promptPlaceholderLabel.leadingAnchor.constraint(equalTo: promptTextView.leadingAnchor, constant: 16),
            promptPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: promptTextView.trailingAnchor, constant: -16)
        ])
        return card
    }

    private func makeDurationSection() -> UIView {
        let card = makeFormCard()
        let stack = makeFormStack(in: card)
        durationSelector.onSelectionChanged = { [weak self] option in
            self?.selectedDuration = option
        }
        durationSelector.select(.standard)

        stack.addArrangedSubview(makeSectionHeader(title: "Duration", trailing: nil))
        stack.addArrangedSubview(durationSelector)
        return card
    }

    private func makeCoverSection() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        coverPicker.onCoverChanged = { [weak self] assetName in
            self?.selectedCoverAssetName = assetName
            self?.selectedCoverLocalImageURI = nil
        }
        coverPicker.onUploadRequested = { [weak self] in
            self?.openPhotoLibrary()
        }
        stack.addArrangedSubview(makeSectionHeader(title: "Cover Photo", trailing: nil))
        stack.addArrangedSubview(coverPicker)
        return stack
    }

    private func makeHeadsUpView() -> UIView {
        LirauCommunityCreateInfoCard(
            systemName: "exclamationmark.triangle.fill",
            title: "Heads up",
            subtitle: "As the host, you cannot submit or vote in your own challenge."
        )
    }

    private func makeVisibilitySection() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.addArrangedSubview(makeSectionHeader(title: "Visibility", trailing: nil))
        stack.addArrangedSubview(LirauCommunityVisibilityCard(language: challengeLanguage))
        return stack
    }

    private func makePublishSection() -> UIView {
        publishButton.setTitle("Publish", for: .normal)
        publishButton.gradientColors = [LirauCommunityPalette.purpleLight, LirauCommunityPalette.green]
        publishButton.addTarget(self, action: #selector(publishChallenge), for: .touchUpInside)

        let wrapper = UIView()
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(publishButton)

        NSLayoutConstraint.activate([
            publishButton.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 4),
            publishButton.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            publishButton.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            publishButton.heightAnchor.constraint(equalToConstant: 48),
            publishButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 132)
        ])
        return wrapper
    }

    private func makeFormCard() -> UIView {
        let card = UIView()
        card.applyLirauCommunityChrome(
            backgroundColor: LirauCommunityPalette.card.withAlphaComponent(0.96),
            cornerRadius: 20,
            borderAlpha: 0.08,
            shadowAlpha: 0.08
        )
        return card
    }

    private func makeFormStack(in card: UIView) -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        stack.isLayoutMarginsRelativeArrangement = true
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        return stack
    }

    private func makeSectionHeader(title: String, trailing: UIView?) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10

        let label = UILabel()
        label.text = title.uppercased()
        label.textColor = LirauCommunityPalette.mutedText
        label.font = .systemFont(ofSize: 11, weight: .black)

        row.addArrangedSubview(label)
        row.addArrangedSubview(UIView())
        if let trailing {
            row.addArrangedSubview(trailing)
        }
        return row
    }

    private func makeHelperLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = LirauCommunityPalette.dimText
        label.font = .systemFont(ofSize: 11, weight: .medium)
        return label
    }

    private func configureTitleField() {
        titleField.delegate = self
        titleField.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        titleField.layer.cornerRadius = 16
        titleField.textColor = .white
        titleField.font = .systemFont(ofSize: 14, weight: .semibold)
        titleField.attributedPlaceholder = NSAttributedString(
            string: "e.g. Today's Mood in Spanish",
            attributes: [.foregroundColor: LirauCommunityPalette.dimText]
        )
        titleField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        titleField.leftViewMode = .always
        titleField.returnKeyType = .next
        titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)

        titleCountLabel.textColor = LirauCommunityPalette.dimText
        titleCountLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleCountLabel.textAlignment = .right
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === titleField {
            promptTextView.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === titleField,
              let text = textField.text,
              let swiftRange = Range(range, in: text) else {
            return true
        }
        let updated = text.replacingCharacters(in: swiftRange, with: string)
        return updated.count <= maxTitleLength
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView === promptTextView, textView.text.count > maxPromptLength {
            textView.text = String(textView.text.prefix(maxPromptLength))
        }
        promptPlaceholderLabel.isHidden = !promptTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let converted = view.convert(frame, from: nil)
        let inset = max(0, view.bounds.maxY - converted.minY) + 18
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 28
        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 28, right: 0)
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }

    @objc private func titleChanged() {
        updatePublishState()
    }

    @objc private func closePage() {
        if let navigationController, navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func updatePublishState() {
        let titleCount = titleField.text?.count ?? 0
        titleCountLabel.text = "\(titleCount) / \(maxTitleLength)"
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let canPublish = !title.isEmpty && title.count <= maxTitleLength && !isPublishing
        publishButton.isEnabled = canPublish
        publishButton.alpha = canPublish ? 1 : 0.42
        publishButton.gradientColors = canPublish
            ? [LirauCommunityPalette.purpleLight, LirauCommunityPalette.green]
            : [UIColor.white.withAlphaComponent(0.18), UIColor.white.withAlphaComponent(0.09)]
    }

    @objc private func publishChallenge() {
        guard !isPublishing else { return }
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else {
            showToast("Add a challenge title.")
            updatePublishState()
            return
        }

        isPublishing = true
        updatePublishState()
        view.endEditing(true)

        let prompt = promptTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let challenge = store.createChallenge(
            draft: LirauCommunityChallengeDraft(
                title: title,
                language: challengeLanguage,
                prompt: prompt,
                coverAssetName: selectedCoverAssetName,
                localImageURI: selectedCoverLocalImageURI,
                durationHours: selectedDuration.hours
            )
        )

        NSLog("LiraU Community challenge created: %@", title)
        if let onCreated {
            onCreated(challenge)
        } else {
            closePage()
        }
    }

    private func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showToast("Photo library is unavailable.")
            return
        }
        view.endEditing(true)
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        picker.dismiss(animated: true) { [weak self] in
            guard let self, let image else {
                self?.showToast("Could not read that image.")
                return
            }
            guard let localPath = self.saveCoverImage(image) else {
                self.showToast("Could not save that cover.")
                return
            }
            self.selectedCoverLocalImageURI = localPath
            self.coverPicker.setPickedImage(image)
            self.updatePublishState()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    private func saveCoverImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.86) else { return nil }
        do {
            let directory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("LiraUCommunityCovers", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let fileURL = directory.appendingPathComponent("lirau_cover_\(UUID().uuidString).jpg")
            try data.write(to: fileURL, options: .atomic)
            return fileURL.path
        } catch {
            NSLog("LiraU Community cover save failed: %@", error.localizedDescription)
            return nil
        }
    }
}
