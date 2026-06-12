import UIKit

final class LirauCommunityEntryInputCard: UIView, UITextViewDelegate {
    var onTextChanged: ((String) -> Void)?

    private let maxLength: Int
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let countLabel = UILabel()

    var sentence: String {
        textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(placeholder: String, maxLength: Int = 120) {
        self.maxLength = maxLength
        super.init(frame: .zero)
        build(placeholder: placeholder)
        updateCount()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func focusTextInput() {
        textView.becomeFirstResponder()
    }

    private func build(placeholder: String) {
        applyLirauCommunityChrome(
            backgroundColor: LirauCommunityPalette.card.withAlphaComponent(0.97),
            cornerRadius: 20,
            borderAlpha: 0.08,
            shadowAlpha: 0.1
        )

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 11
        stack.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        stack.isLayoutMarginsRelativeArrangement = true
        addSubview(stack)

        let label = UILabel()
        label.text = "YOUR SENTENCE"
        label.textColor = LirauCommunityPalette.mutedText
        label.font = .systemFont(ofSize: 11, weight: .black)

        countLabel.textColor = LirauCommunityPalette.dimText
        countLabel.font = .systemFont(ofSize: 11, weight: .bold)
        countLabel.textAlignment = .right

        let header = UIStackView(arrangedSubviews: [label, UIView(), countLabel])
        header.axis = .horizontal
        header.alignment = .center

        let textContainer = UIView()
        textContainer.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        textContainer.layer.cornerRadius = 16
        textContainer.clipsToBounds = true

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 15, weight: .semibold)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 34, right: 10)
        textView.keyboardDismissMode = .interactive
        textContainer.addSubview(textView)

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = LirauCommunityPalette.dimText
        placeholderLabel.font = .systemFont(ofSize: 15, weight: .medium)
        placeholderLabel.numberOfLines = 0
        textContainer.addSubview(placeholderLabel)

        let iconRow = UIStackView()
        iconRow.translatesAutoresizingMaskIntoConstraints = false
        iconRow.axis = .horizontal
        iconRow.alignment = .center
        iconRow.spacing = 10
        iconRow.addArrangedSubview(makeDisabledIcon("mic.fill"))
        iconRow.addArrangedSubview(makeDisabledIcon("character.bubble.fill"))
        textContainer.addSubview(iconRow)

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(textContainer)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            textContainer.heightAnchor.constraint(equalToConstant: 156),

            textView.topAnchor.constraint(equalTo: textContainer.topAnchor),
            textView.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),

            placeholderLabel.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 20),
            placeholderLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -16),

            iconRow.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -14),
            iconRow.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor, constant: -12)
        ])
    }

    private func makeDisabledIcon(_ systemName: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: systemName))
        imageView.tintColor = LirauCommunityPalette.dimText.withAlphaComponent(0.62)
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 18),
            imageView.heightAnchor.constraint(equalToConstant: 18)
        ])
        return imageView
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > maxLength {
            textView.text = String(textView.text.prefix(maxLength))
        }
        updateCount()
        onTextChanged?(sentence)
    }

    private func updateCount() {
        let count = textView.text?.count ?? 0
        countLabel.text = "\(count) / \(maxLength)"
        placeholderLabel.isHidden = !sentence.isEmpty
    }
}

final class LirauCommunityEntrySubmittedModalViewController: UIViewController {
    var onViewChallenge: (() -> Void)?

    private let entryText: String

    init(entryText: String) {
        self.entryText = entryText
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildInterface()
    }

    private func buildInterface() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.72)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyLirauCommunityChrome(
            backgroundColor: LirauCommunityPalette.card,
            cornerRadius: 24,
            borderAlpha: 0.12,
            shadowAlpha: 0.25
        )
        view.addSubview(card)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 15
        stack.layoutMargins = UIEdgeInsets(top: 22, left: 18, bottom: 18, right: 18)
        stack.isLayoutMarginsRelativeArrangement = true
        card.addSubview(stack)

        let checkWrap = UIView()
        checkWrap.translatesAutoresizingMaskIntoConstraints = false
        checkWrap.backgroundColor = LirauCommunityPalette.green
        checkWrap.layer.cornerRadius = 18
        let check = UIImageView(image: UIImage(systemName: "checkmark"))
        check.translatesAutoresizingMaskIntoConstraints = false
        check.tintColor = .white
        check.contentMode = .scaleAspectFit
        checkWrap.addSubview(check)

        let titleLabel = UILabel()
        titleLabel.text = "Entry submitted! 🎉"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 19, weight: .black)

        let messageLabel = UILabel()
        messageLabel.text = "Your sentence is now live. You're officially a participant in this challenge."
        messageLabel.textAlignment = .center
        messageLabel.textColor = LirauCommunityPalette.mutedText
        messageLabel.font = .systemFont(ofSize: 13, weight: .medium)
        messageLabel.numberOfLines = 0

        let preview = makeEntryPreview()

        let viewButton = LirauCommunityGradientButton(type: .system)
        viewButton.setTitle("View challenge", for: .normal)
        viewButton.gradientColors = [LirauCommunityPalette.green, UIColor(red: 0.16, green: 0.82, blue: 0.72, alpha: 1)]
        viewButton.addTarget(self, action: #selector(viewChallengeTapped), for: .touchUpInside)

        let shareButton = UIButton(type: .system)
        shareButton.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        shareButton.layer.cornerRadius = 18
        shareButton.setTitle("Share my entry", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)

        let checkContainer = UIView()
        checkContainer.addSubview(checkWrap)
        NSLayoutConstraint.activate([
            checkWrap.topAnchor.constraint(equalTo: checkContainer.topAnchor),
            checkWrap.centerXAnchor.constraint(equalTo: checkContainer.centerXAnchor),
            checkWrap.bottomAnchor.constraint(equalTo: checkContainer.bottomAnchor),
            checkWrap.widthAnchor.constraint(equalToConstant: 52),
            checkWrap.heightAnchor.constraint(equalToConstant: 52),
            check.centerXAnchor.constraint(equalTo: checkWrap.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: checkWrap.centerYAnchor),
            check.widthAnchor.constraint(equalToConstant: 25),
            check.heightAnchor.constraint(equalToConstant: 25)
        ])

        stack.addArrangedSubview(checkContainer)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)
        stack.addArrangedSubview(preview)
        stack.addArrangedSubview(viewButton)
        stack.addArrangedSubview(shareButton)

        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            viewButton.heightAnchor.constraint(equalToConstant: 46),
            shareButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    private func makeEntryPreview() -> UIView {
        let preview = UIView()
        preview.applyLirauCommunityChrome(
            backgroundColor: LirauCommunityPalette.elevated.withAlphaComponent(0.92),
            cornerRadius: 16,
            borderAlpha: 0.08,
            shadowAlpha: 0.06
        )

        let avatar = UIView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = LirauCommunityPalette.purpleLight
        avatar.layer.cornerRadius = 15

        let title = UILabel()
        title.text = "You"
        title.textColor = .white
        title.font = .systemFont(ofSize: 13, weight: .bold)

        let time = UILabel()
        time.text = "just now"
        time.textColor = LirauCommunityPalette.dimText
        time.font = .systemFont(ofSize: 11, weight: .medium)

        let text = UILabel()
        text.text = entryText
        text.textColor = .white
        text.font = .systemFont(ofSize: 13, weight: .semibold)
        text.numberOfLines = 0

        let header = UIStackView(arrangedSubviews: [title, UIView(), time])
        header.axis = .horizontal
        header.alignment = .center

        let textStack = UIStackView(arrangedSubviews: [header, text])
        textStack.axis = .vertical
        textStack.spacing = 5

        let row = UIStackView(arrangedSubviews: [avatar, textStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 10
        row.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        row.isLayoutMarginsRelativeArrangement = true
        preview.addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: preview.topAnchor),
            row.leadingAnchor.constraint(equalTo: preview.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: preview.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: preview.bottomAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 30),
            avatar.heightAnchor.constraint(equalToConstant: 30)
        ])
        return preview
    }

    @objc private func viewChallengeTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onViewChallenge?()
        }
    }

    @objc private func shareTapped() {
        presentShareSheet(items: ["I joined a LiraU language challenge: \(entryText)"])
    }
}
