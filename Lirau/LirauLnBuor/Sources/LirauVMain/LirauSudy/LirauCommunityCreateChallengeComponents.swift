import UIKit

enum LirauCommunityChallengeDurationOption: CaseIterable {
    case short
    case standard
    case long

    var title: String {
        switch self {
        case .short: return "24h"
        case .standard: return "72h"
        case .long: return "7d"
        }
    }

    var badge: String? {
        switch self {
        case .short: return nil
        case .standard: return "STANDARD"
        case .long: return "LONG"
        }
    }

    var hours: Int {
        switch self {
        case .short: return 24
        case .standard: return 72
        case .long: return 168
        }
    }
}

final class LirauCommunityCreateInfoCard: UIView {
    init(systemName: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        build(systemName: systemName, title: title, subtitle: subtitle)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build(systemName: String, title: String, subtitle: String) {
        applyLirauCommunityChrome(
            backgroundColor: LirauCommunityPalette.elevated.withAlphaComponent(0.96),
            cornerRadius: 17,
            borderAlpha: 0.1,
            shadowAlpha: 0.08
        )

        let iconWrap = UIView()
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.backgroundColor = LirauCommunityPalette.purpleLight.withAlphaComponent(0.22)
        iconWrap.layer.cornerRadius = 13

        let icon = UIImageView(image: UIImage(systemName: systemName))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = LirauCommunityPalette.purpleLight
        icon.contentMode = .scaleAspectFit
        iconWrap.addSubview(icon)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = LirauCommunityPalette.mutedText
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        let row = UIStackView(arrangedSubviews: [iconWrap, textStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.layoutMargins = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
        row.isLayoutMarginsRelativeArrangement = true
        addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconWrap.widthAnchor.constraint(equalToConstant: 42),
            iconWrap.heightAnchor.constraint(equalToConstant: 42),
            icon.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}

final class LirauCommunityDurationSelector: UIView {
    var onSelectionChanged: ((LirauCommunityChallengeDurationOption) -> Void)?
    private(set) var selectedOption: LirauCommunityChallengeDurationOption = .standard
    private var optionViews: [LirauCommunityChallengeDurationOption: LirauCommunityDurationOptionView] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(_ option: LirauCommunityChallengeDurationOption) {
        selectedOption = option
        optionViews.forEach { key, view in
            view.setSelected(key == option)
        }
        onSelectionChanged?(option)
    }

    private func build() {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 9
        stack.distribution = .fillEqually
        addSubview(stack)

        LirauCommunityChallengeDurationOption.allCases.forEach { option in
            let optionView = LirauCommunityDurationOptionView(option: option)
            optionView.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionView.tag = LirauCommunityChallengeDurationOption.allCases.firstIndex(of: option) ?? 0
            optionViews[option] = optionView
            stack.addArrangedSubview(optionView)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 52)
        ])

        select(.standard)
    }

    @objc private func optionTapped(_ sender: UIControl) {
        let options = LirauCommunityChallengeDurationOption.allCases
        guard sender.tag < options.count else { return }
        select(options[sender.tag])
    }
}

private final class LirauCommunityDurationOptionView: UIControl {
    private let titleLabel = UILabel()
    private let badgeLabel = UILabel()

    init(option: LirauCommunityChallengeDurationOption) {
        super.init(frame: .zero)
        build(option: option)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ selected: Bool) {
        backgroundColor = selected ? LirauCommunityPalette.purpleSoft : UIColor.white.withAlphaComponent(0.065)
        layer.borderColor = selected
            ? LirauCommunityPalette.purpleLight.withAlphaComponent(0.62).cgColor
            : UIColor.white.withAlphaComponent(0.07).cgColor
        titleLabel.textColor = selected ? .white : LirauCommunityPalette.mutedText
        badgeLabel.textColor = selected ? LirauCommunityPalette.green : LirauCommunityPalette.dimText
    }

    private func build(option: LirauCommunityChallengeDurationOption) {
        layer.cornerRadius = 15
        layer.borderWidth = 1

        titleLabel.text = option.title
        titleLabel.font = .systemFont(ofSize: 14, weight: .black)
        titleLabel.textAlignment = .center

        badgeLabel.text = option.badge ?? " "
        badgeLabel.font = .systemFont(ofSize: 8, weight: .black)
        badgeLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, badgeLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -6)
        ])
    }
}

final class LirauCommunityLocalCoverPicker: UIView {
    var onCoverChanged: ((String) -> Void)?
    var onUploadRequested: (() -> Void)?
    private(set) var selectedCoverAssetName = "lira_community_challenge_cover"

    private let previewImageView = UIImageView()
    private var optionViews: [String: UIControl] = [:]

    private let coverOptions = [
        "lira_community_challenge_cover",
        "lira_community_challenge_speak_daily",
        "lira_community_challenge_chat",
        "lira_community_challenge_study_together",
        "lira_community_challenge_words"
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
        selectCover(selectedCoverAssetName)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        applyLirauCommunityChrome(
            backgroundColor: LirauCommunityPalette.surface.withAlphaComponent(0.96),
            cornerRadius: 20,
            borderAlpha: 0.08,
            shadowAlpha: 0.08
        )

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        stack.isLayoutMarginsRelativeArrangement = true
        addSubview(stack)

        let uploadControl = UIControl()
        uploadControl.translatesAutoresizingMaskIntoConstraints = false
        uploadControl.layer.cornerRadius = 17
        uploadControl.clipsToBounds = true
        uploadControl.addTarget(self, action: #selector(uploadTapped), for: .touchUpInside)

        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        previewImageView.isUserInteractionEnabled = false
        uploadControl.addSubview(previewImageView)

        let optionStack = UIStackView()
        optionStack.axis = .horizontal
        optionStack.spacing = 8
        optionStack.distribution = .fillEqually

        coverOptions.enumerated().forEach { index, assetName in
            let option = makeOptionView(assetName: assetName, tag: index)
            optionViews[assetName] = option
            optionStack.addArrangedSubview(option)
        }

        stack.addArrangedSubview(uploadControl)
        stack.addArrangedSubview(optionStack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            uploadControl.heightAnchor.constraint(equalToConstant: 150),
            previewImageView.topAnchor.constraint(equalTo: uploadControl.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: uploadControl.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: uploadControl.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: uploadControl.bottomAnchor)
        ])
    }

    private func makeOptionView(assetName: String, tag: Int) -> UIControl {
        let control = UIControl()
        control.tag = tag
        control.layer.cornerRadius = 12
        control.layer.borderWidth = 1.5
        control.clipsToBounds = true
        control.addTarget(self, action: #selector(coverTapped(_:)), for: .touchUpInside)

        let imageView = UIImageView(image: UIImage(named: assetName) ?? UIImage(named: "lira_community_challenge_cover"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        control.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: control.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: control.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: control.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: control.bottomAnchor),
            control.heightAnchor.constraint(equalToConstant: 44)
        ])

        return control
    }

    private func selectCover(_ assetName: String) {
        selectedCoverAssetName = UIImage(named: assetName) == nil ? "lira_community_challenge_cover" : assetName
        if selectedCoverAssetName == "lira_community_challenge_cover" {
            previewImageView.image = UIImage(named: "lira_community_cover_upload_placeholder") ?? UIImage(named: selectedCoverAssetName)
        } else {
            previewImageView.image = UIImage(named: selectedCoverAssetName) ?? UIImage(named: "lira_community_challenge_cover")
        }
        optionViews.forEach { key, view in
            view.layer.borderColor = key == selectedCoverAssetName
                ? LirauCommunityPalette.green.cgColor
                : UIColor.white.withAlphaComponent(0.14).cgColor
        }
        onCoverChanged?(selectedCoverAssetName)
    }

    func setPickedImage(_ image: UIImage) {
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.image = image
        optionViews.forEach { _, view in
            view.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        }
    }

    @objc private func coverTapped(_ sender: UIControl) {
        guard sender.tag < coverOptions.count else { return }
        selectCover(coverOptions[sender.tag])
    }

    @objc private func uploadTapped() {
        onUploadRequested?()
    }
}

final class LirauCommunityVisibilityCard: UIView {
    init(language: String) {
        super.init(frame: .zero)
        build(language: language)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build(language: String) {
        applyLirauCommunityChrome(
            backgroundColor: UIColor.white.withAlphaComponent(0.06),
            cornerRadius: 16,
            borderAlpha: 0.07,
            shadowAlpha: 0.04
        )

        let title = UILabel()
        title.text = "Public challenge"
        title.textColor = .white
        title.font = .systemFont(ofSize: 13, weight: .bold)

        let subtitle = UILabel()
        subtitle.text = "Visible to all \(language) learners"
        subtitle.textColor = LirauCommunityPalette.mutedText
        subtitle.font = .systemFont(ofSize: 12, weight: .medium)
        subtitle.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [title, subtitle])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.layoutMargins = UIEdgeInsets(top: 13, left: 14, bottom: 13, right: 14)
        stack.isLayoutMarginsRelativeArrangement = true
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
