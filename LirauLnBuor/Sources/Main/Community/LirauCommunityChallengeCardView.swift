import UIKit

final class LirauCommunityChallengeCardView: UIControl {
    var onSelect: (() -> Void)?
    var onPrimaryAction: (() -> Void)?
    var onReport: (() -> Void)?

    private let coverImageView = UIImageView()
    private let statusPill = LirauCommunityStatusPill(status: .live)
    private let hotPill = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let participantDotsStack = UIStackView()
    private let joinedLabel = UILabel()
    private let voteLabel = UILabel()
    private let likeLabel = UILabel()
    private let likeIconView = UIImageView()
    private let voteIconView = UIImageView()
    private let dividerView = UIView()
    private let primaryButton = LirauCommunityGradientButton(type: .system)
    private let reportButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildCard()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with challenge: LirauCommunityChallenge) {
        coverImageView.image = challenge.displayCoverImage
        statusPill.setStatus(challenge.status)
        hotPill.isHidden = !challenge.isHot
        titleLabel.text = challenge.title
        subtitleLabel.text = challenge.subtitle
        joinedLabel.text = challenge.participantText
        voteLabel.text = challenge.voteText
        likeLabel.text = "\(challenge.likeCount)"
        primaryButton.setTitle(primaryActionTitle(for: challenge), for: .normal)
        primaryButton.accessibilityLabel = primaryActionTitle(for: challenge)
        rebuildParticipantDots(for: challenge)

        let isLive = challenge.status == .live
        let highlightedLike = isLive || challenge.isLikedByCurrentUser
        likeIconView.image = UIImage(systemName: highlightedLike ? "heart.fill" : "heart")
        likeIconView.tintColor = highlightedLike ? UIColor(red: 1.0, green: 0.35, blue: 0.48, alpha: 1) : LirauCommunityPalette.mutedText
        likeLabel.textColor = highlightedLike ? UIColor(red: 1.0, green: 0.35, blue: 0.48, alpha: 1) : LirauCommunityPalette.mutedText
        voteIconView.tintColor = LirauCommunityPalette.mutedText
        voteLabel.textColor = LirauCommunityPalette.mutedText

        if challenge.status == .ended || challenge.currentUserMode == .host || challenge.currentUserMode == .submitted || !challenge.recordedVotedEntryIDs.isEmpty {
            primaryButton.gradientColors = [UIColor.white.withAlphaComponent(0.2), UIColor.white.withAlphaComponent(0.1)]
            primaryButton.setTitleColor(challenge.status == .ended ? LirauCommunityPalette.mutedText : .white, for: .normal)
        } else {
            primaryButton.gradientColors = [LirauCommunityPalette.purpleLight, LirauCommunityPalette.purple]
            primaryButton.setTitleColor(.white, for: .normal)
        }
    }

    private func primaryActionTitle(for challenge: LirauCommunityChallenge) -> String {
        if challenge.phase == .ended {
            return "See results"
        }

        switch challenge.currentUserMode {
        case .host:
            return "View"
        case .submitted:
            return challenge.phase == .open ? "Joined" : "View"
        case .voteOnly:
            return challenge.recordedVotedEntryIDs.isEmpty ? "Vote" : "Voting"
        case .none:
            switch challenge.phase {
            case .open:
                return "Join"
            case .voting:
                return "Vote"
            case .ended:
                return "See results"
            }
        }
    }

    private func buildCard() {
        applyLirauCommunityChrome(cornerRadius: 24, borderAlpha: 0.09, shadowAlpha: 0.16)
        addTarget(self, action: #selector(cardTapped), for: .touchUpInside)

        let coverContainer = UIView()
        coverContainer.translatesAutoresizingMaskIntoConstraints = false
        coverContainer.layer.cornerRadius = 18
        coverContainer.clipsToBounds = true
        coverContainer.backgroundColor = LirauCommunityPalette.elevated
        coverContainer.isUserInteractionEnabled = false
        addSubview(coverContainer)

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverContainer.addSubview(coverImageView)

        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.setContentHuggingPriority(.required, for: .horizontal)
        statusPill.setContentCompressionResistancePriority(.required, for: .horizontal)

        hotPill.translatesAutoresizingMaskIntoConstraints = false
        hotPill.text = "Hot"
        hotPill.textAlignment = .center
        hotPill.textColor = .white
        hotPill.font = .systemFont(ofSize: 11, weight: .bold)
        hotPill.backgroundColor = LirauCommunityPalette.purpleLight.withAlphaComponent(0.23)
        hotPill.layer.cornerRadius = 10
        hotPill.layer.borderWidth = 1
        hotPill.layer.borderColor = LirauCommunityPalette.purpleLight.withAlphaComponent(0.26).cgColor
        hotPill.clipsToBounds = true
        hotPill.setContentHuggingPriority(.required, for: .horizontal)
        hotPill.setContentCompressionResistancePriority(.required, for: .horizontal)

        let statusRow = UIStackView(arrangedSubviews: [statusPill, hotPill])
        statusRow.axis = .horizontal
        statusRow.alignment = .center
        statusRow.spacing = 7
        statusRow.isUserInteractionEnabled = false

        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.backgroundColor = nil
        reportButton.layer.cornerRadius = 13
        reportButton.tintColor = LirauCommunityPalette.purple
        reportButton.setImage(UIImage(systemName: "exclamationmark.bubble.fill"), for: .normal)
        reportButton.isUserInteractionEnabled = true
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
        addSubview(reportButton)

        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        subtitleLabel.font = .systemFont(ofSize: 12.5, weight: .semibold)
        subtitleLabel.textColor = LirauCommunityPalette.mutedText
        subtitleLabel.numberOfLines = 1

        participantDotsStack.axis = .horizontal
        participantDotsStack.alignment = .center
        participantDotsStack.spacing = -3
        participantDotsStack.isUserInteractionEnabled = false

        joinedLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        joinedLabel.textColor = LirauCommunityPalette.mutedText

        let participantRow = UIStackView(arrangedSubviews: [participantDotsStack, joinedLabel])
        participantRow.axis = .horizontal
        participantRow.alignment = .center
        participantRow.spacing = 9
        participantRow.isUserInteractionEnabled = false

        let textStack = UIStackView(arrangedSubviews: [statusRow, titleLabel, subtitleLabel, participantRow])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 5
        textStack.isUserInteractionEnabled = false
        addSubview(textStack)

        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = UIColor.white.withAlphaComponent(0.075)
        dividerView.isUserInteractionEnabled = false
        addSubview(dividerView)

        [likeLabel, voteLabel].forEach {
            $0.font = .systemFont(ofSize: 12.5, weight: .semibold)
            $0.textColor = LirauCommunityPalette.mutedText
        }

        likeIconView.image = UIImage(systemName: "heart")
        likeIconView.tintColor = LirauCommunityPalette.mutedText
        likeIconView.contentMode = .scaleAspectFit

        voteIconView.image = UIImage(systemName: "checkmark.square")
        voteIconView.tintColor = LirauCommunityPalette.mutedText
        voteIconView.contentMode = .scaleAspectFit

        let bottomMetrics = UIStackView(arrangedSubviews: [
            makeIconMetric(imageView: likeIconView, label: likeLabel),
            makeIconMetric(imageView: voteIconView, label: voteLabel)
        ])
        bottomMetrics.axis = .horizontal
        bottomMetrics.alignment = .center
        bottomMetrics.spacing = 16
        bottomMetrics.isUserInteractionEnabled = false

        primaryButton.isUserInteractionEnabled = true
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        primaryButton.setContentHuggingPriority(.required, for: .horizontal)
        primaryButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let actionSpacer = UIView()
        let actionRow = UIStackView(arrangedSubviews: [bottomMetrics, actionSpacer, primaryButton])
        actionRow.translatesAutoresizingMaskIntoConstraints = false
        actionRow.axis = .horizontal
        actionRow.alignment = .center
        actionRow.spacing = 12
        addSubview(actionRow)

        let dividerBelowCover = dividerView.topAnchor.constraint(equalTo: coverContainer.bottomAnchor, constant: 14)
        dividerBelowCover.priority = .defaultHigh

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 188),

            coverContainer.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            coverContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            coverContainer.widthAnchor.constraint(equalToConstant: 92),
            coverContainer.heightAnchor.constraint(equalToConstant: 92),

            coverImageView.topAnchor.constraint(equalTo: coverContainer.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: coverContainer.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: coverContainer.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverContainer.bottomAnchor),

            textStack.topAnchor.constraint(equalTo: coverContainer.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: coverContainer.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statusPill.heightAnchor.constraint(equalToConstant: 20),
            statusPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 58),
            hotPill.heightAnchor.constraint(equalToConstant: 20),
            hotPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),

            reportButton.topAnchor.constraint(equalTo: coverContainer.topAnchor, constant: 10),
            reportButton.trailingAnchor.constraint(equalTo: coverContainer.trailingAnchor, constant: -10),
            reportButton.widthAnchor.constraint(equalToConstant: 26),
            reportButton.heightAnchor.constraint(equalToConstant: 26),

            dividerBelowCover,
            dividerView.topAnchor.constraint(greaterThanOrEqualTo: textStack.bottomAnchor, constant: 12),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dividerView.heightAnchor.constraint(equalToConstant: 1),

            actionRow.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 11),
            actionRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            actionRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actionRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            actionRow.heightAnchor.constraint(equalToConstant: 40),
            primaryButton.heightAnchor.constraint(equalToConstant: 40),
            primaryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 86)
        ])
    }

    private func makeIconMetric(imageView: UIImageView, label: UILabel) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(label)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 14),
            imageView.heightAnchor.constraint(equalToConstant: 14)
        ])
        return stack
    }

    private func rebuildParticipantDots(for challenge: LirauCommunityChallenge) {
        participantDotsStack.removeAllArrangedSubviews()
        let entryColors = challenge.entries.prefix(3).map { UIColor(lirauHex: $0.colorHex) }
        let fallbackColors = [
            UIColor(red: 1.0, green: 0.46, blue: 0.36, alpha: 1),
            UIColor(red: 0.31, green: 0.83, blue: 0.9, alpha: 1),
            LirauCommunityPalette.purple
        ]
        let colors = entryColors.isEmpty ? Array(fallbackColors.prefix(2)) : entryColors
        colors.forEach { color in
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = color
            dot.layer.cornerRadius = 8
            dot.layer.borderWidth = 1
            dot.layer.borderColor = LirauCommunityPalette.card.cgColor
            participantDotsStack.addArrangedSubview(dot)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 16),
                dot.heightAnchor.constraint(equalToConstant: 16)
            ])
        }
    }

    @objc private func cardTapped() {
        onSelect?()
    }

    @objc private func primaryTapped() {
        onPrimaryAction?()
    }

    @objc private func reportTapped() {
        onReport?()
    }
}
