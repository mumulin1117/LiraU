import UIKit

final class LirauCommunityResultViewController: UIViewController {
    private let challengeID: String
    private let store = LirauCommunityLocalStore.shared
    private let backgroundView = LirauCommunityBackgroundView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    init(challengeID: String) {
        self.challengeID = challengeID
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildBase()
        reloadContent()
    }

    private func buildBase() {
        view.backgroundColor = LirauCommunityPalette.background
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 32, right: 20)
        contentStack.isLayoutMarginsRelativeArrangement = true
        scrollView.addSubview(contentStack)

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

    private func reloadContent() {
        contentStack.removeAllArrangedSubviews()
        guard let challenge = store.challenge(with: challengeID) else {
            contentStack.addArrangedSubview(makeTopRow(title: "Results"))
            contentStack.addArrangedSubview(LirauCommunityEmptyStateView(message: "Result data is unavailable."))
            return
        }
        let ranked = challenge.entries.sorted { $0.voteCount > $1.voteCount }
        contentStack.addArrangedSubview(makeTopRow(title: "Results"))
        contentStack.addArrangedSubview(makeResultHero(challenge))
        contentStack.addArrangedSubview(makePodium(entries: Array(ranked.prefix(3))))
        contentStack.addArrangedSubview(makeRankingList(entries: ranked))
        contentStack.addArrangedSubview(makeResultActions(challenge))
    }

    private func makeTopRow(title: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        let backButton = LirauCommunityIconButton(systemName: "chevron.left")
        backButton.addTarget(self, action: #selector(closePage), for: .touchUpInside)
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        row.addArrangedSubview(backButton)
        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(UIView())
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        return row
    }

    private func makeResultHero(_ challenge: LirauCommunityChallenge) -> UIView {
        let card = UIView()
        card.backgroundColor = LirauCommunityPalette.card
        card.layer.cornerRadius = 22

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.layoutMargins = UIEdgeInsets(top: 22, left: 18, bottom: 22, right: 18)
        stack.isLayoutMarginsRelativeArrangement = true
        card.addSubview(stack)

        let trophy = UIImageView(image: UIImage(named: "lira_community_result_trophy") ?? UIImage(systemName: "trophy.fill"))
        trophy.translatesAutoresizingMaskIntoConstraints = false
        trophy.contentMode = .scaleAspectFit
        trophy.tintColor = LirauCommunityPalette.yellow

        let title = UILabel()
        title.text = "Challenge Complete!"
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.textColor = .white

        let subtitle = UILabel()
        subtitle.text = challenge.title
        subtitle.font = .systemFont(ofSize: 13, weight: .semibold)
        subtitle.textColor = LirauCommunityPalette.mutedText
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0

        stack.addArrangedSubview(trophy)
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            trophy.widthAnchor.constraint(equalToConstant: 58),
            trophy.heightAnchor.constraint(equalToConstant: 58)
        ])
        return card
    }

    private func makePodium(entries: [LirauCommunityEntry]) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.alignment = .bottom
        container.distribution = .fillEqually
        container.spacing = 8

        if entries.isEmpty {
            container.addArrangedSubview(LirauCommunityEmptyStateView(message: "No entries were submitted."))
            return container
        }

        entries.enumerated().forEach { index, entry in
            let rank = index + 1
            let card = LirauCommunityPodiumView(rank: rank, entry: entry)
            card.onTap = { [weak self] in self?.showWinner(entry, rank: rank) }
            container.addArrangedSubview(card)
        }
        return container
    }

    private func makeRankingList(entries: [LirauCommunityEntry]) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10

        let title = UILabel()
        title.text = "Full Ranking"
        title.textColor = .white
        title.font = .systemFont(ofSize: 16, weight: .bold)
        stack.addArrangedSubview(title)

        entries.enumerated().forEach { index, entry in
            let row = LirauCommunityRankingRow(rank: index + 1, entry: entry)
            row.onTap = { [weak self] in self?.showWinner(entry, rank: index + 1) }
            stack.addArrangedSubview(row)
        }
        return stack
    }

    private func makeResultActions(_ challenge: LirauCommunityChallenge) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10

        let shareButton = LirauCommunityGradientButton(type: .system)
        shareButton.setTitle("Share Results", for: .normal)
        shareButton.addTarget(self, action: #selector(shareResults), for: .touchUpInside)

        let nextButton = UIButton(type: .system)
        nextButton.setTitle("Next Challenge", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        nextButton.layer.cornerRadius = 18
        nextButton.addTarget(self, action: #selector(openNextChallenge), for: .touchUpInside)

        stack.addArrangedSubview(shareButton)
        stack.addArrangedSubview(nextButton)
        NSLayoutConstraint.activate([
            shareButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        return stack
    }

    private func showWinner(_ entry: LirauCommunityEntry, rank: Int) {
        let sheet = LirauCommunityWinnerSheetController(entry: entry, rank: rank)
        sheet.onViewProfile = { [weak self] userID in
            self?.openLearnerProfile(userID)
        }
        present(sheet, animated: false)
    }

    private func openLearnerProfile(_ userID: String) {
        let controller = LirauDeepLinkingLorauaPortalViewController(deepLinkingLorauaEntryURLString: LirauDeepLinkingLorauaRoute.languageExchangePartnerLorauaProfilePath(userID: userID))
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func closePage() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func shareResults() {
        guard let challenge = store.challenge(with: challengeID) else { return }
        presentShareSheet(items: ["LiraU challenge results: \(challenge.title)"])
    }

    @objc private func openNextChallenge() {
        guard let next = store.loadChallenges().first(where: { $0.status != .ended && $0.id != challengeID }) else {
            showToast("No active challenge is available now.")
            return
        }
        let controller = LirauCommunityChallengeDetailViewController(challengeID: next.id)
        navigationController?.pushViewController(controller, animated: true)
    }
}

final class LirauCommunityPodiumView: UIControl {
    var onTap: (() -> Void)?

    init(rank: Int, entry: LirauCommunityEntry) {
        super.init(frame: .zero)
        build(rank: rank, entry: entry)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build(rank: Int, entry: LirauCommunityEntry) {
        backgroundColor = LirauCommunityPalette.card
        layer.cornerRadius = 18

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.layoutMargins = UIEdgeInsets(top: rank == 1 ? 18 : 14, left: 8, bottom: 14, right: 8)
        stack.isLayoutMarginsRelativeArrangement = true
        addSubview(stack)

        let rankLabel = UILabel()
        rankLabel.text = "#\(rank)"
        rankLabel.textColor = rank == 1 ? LirauCommunityPalette.yellow : LirauCommunityPalette.mutedText
        rankLabel.font = .systemFont(ofSize: 16, weight: .black)

        let avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = UIColor(lirauHex: entry.colorHex)
        avatar.layer.cornerRadius = 20
        avatar.clipsToBounds = true

        let name = UILabel()
        name.text = entry.userName
        name.textColor = .white
        name.font = .systemFont(ofSize: 12, weight: .bold)
        name.textAlignment = .center
        name.numberOfLines = 2

        let votes = UILabel()
        votes.text = "\(entry.voteCount)"
        votes.textColor = LirauCommunityPalette.mutedText
        votes.font = .systemFont(ofSize: 11, weight: .semibold)

        stack.addArrangedSubview(rankLabel)
        stack.addArrangedSubview(avatar)
        stack.addArrangedSubview(name)
        stack.addArrangedSubview(votes)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40),
            heightAnchor.constraint(equalToConstant: rank == 1 ? 148 : 132)
        ])
    }

    @objc private func tapped() {
        onTap?()
    }
}

final class LirauCommunityRankingRow: UIControl {
    var onTap: (() -> Void)?

    init(rank: Int, entry: LirauCommunityEntry) {
        super.init(frame: .zero)
        build(rank: rank, entry: entry)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build(rank: Int, entry: LirauCommunityEntry) {
        backgroundColor = LirauCommunityPalette.card
        layer.cornerRadius = 16

        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        row.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        row.isLayoutMarginsRelativeArrangement = true
        addSubview(row)

        let rankLabel = UILabel()
        rankLabel.text = "\(rank)"
        rankLabel.textColor = rank <= 3 ? LirauCommunityPalette.yellow : LirauCommunityPalette.mutedText
        rankLabel.font = .systemFont(ofSize: 15, weight: .bold)
        rankLabel.textAlignment = .center

        let nameLabel = UILabel()
        nameLabel.text = entry.userName
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 14, weight: .bold)

        let sentenceLabel = UILabel()
        sentenceLabel.text = entry.sentence
        sentenceLabel.textColor = LirauCommunityPalette.mutedText
        sentenceLabel.font = .systemFont(ofSize: 12, weight: .medium)
        sentenceLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [nameLabel, sentenceLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        let votesLabel = UILabel()
        votesLabel.text = "\(entry.voteCount)"
        votesLabel.font = .systemFont(ofSize: 13, weight: .bold)
        votesLabel.textColor = LirauCommunityPalette.purpleLight

        row.addArrangedSubview(rankLabel)
        row.addArrangedSubview(textStack)
        row.addArrangedSubview(votesLabel)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 28),
            votesLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 38)
        ])
    }

    @objc private func tapped() {
        onTap?()
    }
}

final class LirauCommunityWinnerSheetController: UIViewController {
    var onViewProfile: ((String) -> Void)?
    private let entry: LirauCommunityEntry
    private let rank: Int

    init(entry: LirauCommunityEntry, rank: Int) {
        self.entry = entry
        self.rank = rank
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
        buildSheet()
    }

    private func buildSheet() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.58)

        let dimButton = UIControl()
        dimButton.translatesAutoresizingMaskIntoConstraints = false
        dimButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(dimButton)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = LirauCommunityPalette.card
        card.layer.cornerRadius = 24
        view.addSubview(card)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        card.addSubview(stack)

        let trophy = UIImageView(image: UIImage(named: "lira_community_result_trophy") ?? UIImage(systemName: "trophy.fill"))
        trophy.translatesAutoresizingMaskIntoConstraints = false
        trophy.contentMode = .scaleAspectFit
        trophy.tintColor = LirauCommunityPalette.yellow

        let title = UILabel()
        title.text = rank == 1 ? "Winner Spotlight" : "Rank #\(rank)"
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.textColor = .white

        let name = UILabel()
        name.text = entry.userName
        name.font = .systemFont(ofSize: 14, weight: .bold)
        name.textColor = LirauCommunityPalette.purpleLight

        let sentence = UILabel()
        sentence.text = entry.sentence
        sentence.font = .systemFont(ofSize: 15, weight: .bold)
        sentence.textColor = .white
        sentence.textAlignment = .center
        sentence.numberOfLines = 0

        let translation = UILabel()
        translation.text = entry.translation
        translation.font = .systemFont(ofSize: 12, weight: .medium)
        translation.textColor = LirauCommunityPalette.mutedText
        translation.textAlignment = .center
        translation.numberOfLines = 0

        let metrics = UILabel()
        metrics.text = "\(entry.voteCount) votes  •  \(entry.accentNote)"
        metrics.font = .systemFont(ofSize: 12, weight: .semibold)
        metrics.textColor = LirauCommunityPalette.dimText
        metrics.textAlignment = .center
        metrics.numberOfLines = 0

        let profileButton = LirauCommunityGradientButton(type: .system)
        profileButton.setTitle("View Profile", for: .normal)
        profileButton.addTarget(self, action: #selector(viewProfile), for: .touchUpInside)

        let followButton = UIButton(type: .system)
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(.white, for: .normal)
        followButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        followButton.layer.cornerRadius = 18
        followButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        followButton.addTarget(self, action: #selector(followTapped), for: .touchUpInside)

        stack.addArrangedSubview(trophy)
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(name)
        stack.addArrangedSubview(sentence)
        stack.addArrangedSubview(translation)
        stack.addArrangedSubview(metrics)
        stack.addArrangedSubview(profileButton)
        stack.addArrangedSubview(followButton)

        NSLayoutConstraint.activate([
            dimButton.topAnchor.constraint(equalTo: view.topAnchor),
            dimButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            trophy.widthAnchor.constraint(equalToConstant: 56),
            trophy.heightAnchor.constraint(equalToConstant: 56),
            profileButton.heightAnchor.constraint(equalToConstant: 42),
            profileButton.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 1),
            followButton.heightAnchor.constraint(equalToConstant: 42),
            followButton.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 1)
        ])
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func viewProfile() {
        let userID = entry.userID
        dismiss(animated: true) { [weak self] in
            self?.onViewProfile?(userID)
        }
    }

    @objc private func followTapped() {
        showToast("Follow request saved locally.")
    }
}
