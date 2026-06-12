import UIKit

final class LirauLaungeStudyViewController: UIViewController {
    private let store = LirauCommunityLocalStore.shared
    private var selectedFilter: LirauCommunityFilter = .all
    private var visibleChallenges: [LirauCommunityChallenge] = []

    private let backgroundView = LirauCommunityBackgroundView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let challengeStack = UIStackView()
    private let filterTabs = LirauCommunityFilterTabsView()
    private let emptyView = LirauCommunityEmptyStateView(message: "No language challenges here yet.")

    private lazy var floatingCreateButton: LirauCommunityGradientButton = {
        let button = LirauCommunityGradientButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = false
        button.layer.cornerRadius = 24
        button.layer.shadowColor = LirauCommunityPalette.purple.cgColor
        button.layer.shadowOpacity = 0.34
        button.layer.shadowRadius = 20
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
        button.gradientColors = [LirauCommunityPalette.purpleLight, LirauCommunityPalette.purple]
        button.tintColor = .white
        let image = UIImage(named: "lira_community_create_icon") ?? UIImage(systemName: "plus")
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setTitle("  Create", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.addTarget(self, action: #selector(openCreateChallenge), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildInterface()
        reloadChallenges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadChallenges()
    }

    private func buildInterface() {
        view.backgroundColor = LirauCommunityPalette.background
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset.bottom = 132
        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 132, right: 0)
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 17
        contentStack.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 116, right: 18)
        contentStack.isLayoutMarginsRelativeArrangement = true
        scrollView.addSubview(contentStack)

        challengeStack.axis = .vertical
        challengeStack.spacing = 16

        contentStack.addArrangedSubview(makeTitleRow())
        contentStack.addArrangedSubview(makeAIBanner())
        filterTabs.onFilterChanged = { [weak self] filter in
            self?.selectedFilter = filter
            self?.reloadChallenges()
        }
        contentStack.addArrangedSubview(filterTabs)
        contentStack.addArrangedSubview(makeSectionHeader())
        contentStack.addArrangedSubview(challengeStack)
        emptyView.isHidden = true
        contentStack.addArrangedSubview(emptyView)

        view.addSubview(floatingCreateButton)

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

            floatingCreateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingCreateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            floatingCreateButton.heightAnchor.constraint(equalToConstant: 48),
            floatingCreateButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 128)
        ])
    }

    private func makeTitleRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let titleLabel = UILabel()
        titleLabel.text = "Community"
        titleLabel.font = .systemFont(ofSize: 30, weight: .black)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.86

        let subtitleLabel = UILabel()
        subtitleLabel.text = "LinguaMate challenges"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = LirauCommunityPalette.mutedText

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let createButton = UIButton(type: .system)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.layer.cornerRadius = 17
        createButton.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        createButton.tintColor = .white
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        let image = UIImage(named: "lira_community_create_icon") ?? UIImage(systemName: "square.and.pencil")
        createButton.tintColor = LirauCommunityPalette.purple
        createButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        createButton.addTarget(self, action: #selector(openCreateChallenge), for: .touchUpInside)

        row.addArrangedSubview(textStack)
        row.addArrangedSubview(UIView())
        row.addArrangedSubview(createButton)

        NSLayoutConstraint.activate([
            createButton.widthAnchor.constraint(equalToConstant: 34),
            createButton.heightAnchor.constraint(equalToConstant: 34)
        ])
        return row
    }

    private func makeAIBanner() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 20
        container.clipsToBounds = true
        container.backgroundColor = LirauCommunityPalette.card
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        let imageView = UIImageView(image: UIImage(named: "lira_community_ai_banner"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        container.addSubview(imageView)

        let tapArea = UIControl()
        tapArea.translatesAutoresizingMaskIntoConstraints = false
        tapArea.addTarget(self, action: #selector(openAIMentor), for: .touchUpInside)
        container.addSubview(tapArea)

        let fallbackTitle = UILabel()
        fallbackTitle.translatesAutoresizingMaskIntoConstraints = false
        fallbackTitle.text = "LinguaMate (AI)"
        fallbackTitle.textColor = .white
        fallbackTitle.font = .systemFont(ofSize: 22, weight: .black)
        fallbackTitle.isHidden = imageView.image != nil
        container.addSubview(fallbackTitle)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 165.0 / 343.0),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            tapArea.topAnchor.constraint(equalTo: container.topAnchor),
            tapArea.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tapArea.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tapArea.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            fallbackTitle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            fallbackTitle.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    private func makeSectionHeader() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let markContainer = UIView()
        markContainer.translatesAutoresizingMaskIntoConstraints = false
        markContainer.backgroundColor = LirauCommunityPalette.elevated.withAlphaComponent(0.9)
        markContainer.layer.cornerRadius = 15
        markContainer.layer.borderWidth = 1
        markContainer.layer.borderColor = LirauCommunityPalette.purpleLight.withAlphaComponent(0.36).cgColor

        let markView = UIImageView(image: UIImage(named: "lira_community_result_trophy") ?? UIImage(systemName: "trophy"))
        markView.translatesAutoresizingMaskIntoConstraints = false
        markView.tintColor = LirauCommunityPalette.purpleLight
        markView.contentMode = .scaleAspectFit
        markContainer.addSubview(markView)

        let label = UILabel()
        label.text = "Language Challenges"
        label.font = .systemFont(ofSize: 20, weight: .black)
        label.textColor = .white

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Join a challenge. Learn together."
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = LirauCommunityPalette.dimText

        let textStack = UIStackView(arrangedSubviews: [label, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        row.addArrangedSubview(markContainer)
        row.addArrangedSubview(textStack)
        row.addArrangedSubview(UIView())

        NSLayoutConstraint.activate([
            markContainer.widthAnchor.constraint(equalToConstant: 44),
            markContainer.heightAnchor.constraint(equalToConstant: 44),
            markView.centerXAnchor.constraint(equalTo: markContainer.centerXAnchor),
            markView.centerYAnchor.constraint(equalTo: markContainer.centerYAnchor),
            markView.widthAnchor.constraint(equalToConstant: 24),
            markView.heightAnchor.constraint(equalToConstant: 24)
        ])
        return row
    }

    private func reloadChallenges() {
        let allChallenges = store.loadChallenges()
        visibleChallenges = allChallenges.filter { challenge in
            switch selectedFilter {
            case .all:
                return true
            case .ended:
                return challenge.status == .ended
            case .hot:
                return challenge.isHot
            }
        }

        challengeStack.removeAllArrangedSubviews()
        visibleChallenges.forEach { challenge in
            let card = LirauCommunityChallengeCardView()
            card.configure(with: challenge)
            card.onSelect = { [weak self] in self?.openChallengeDetail(challenge.id) }
            card.onPrimaryAction = { [weak self] in self?.handlePrimaryAction(for: challenge) }
            card.onReport = { [weak self] in self?.showReportNotice(target: challenge.title) }
            challengeStack.addArrangedSubview(card)
        }
        emptyView.isHidden = !visibleChallenges.isEmpty
    }

    private func handlePrimaryAction(for challenge: LirauCommunityChallenge) {
        openChallengeDetail(challenge.id)
    }

    private func openChallengeDetail(_ challengeID: String) {
        let controller = LirauCommunityChallengeDetailViewController(challengeID: challengeID)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func openAIMentor() {
        let controller = LirauDeepLinkingLorauaPortalViewController(deepLinkingLorauaEntryURLString: LirauDeepLinkingLorauaRoute.languageMentorshipLorauaAIPath())
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func openCreateChallenge() {
        let controller = LirauCommunityCreateChallengeViewController()
        controller.onCreated = { [weak self, weak controller] challenge in
            controller?.dismiss(animated: true) {
                guard let self else { return }
                self.selectedFilter = .all
                self.filterTabs.setSelectedFilter(.all)
                self.reloadChallenges()
                self.openChallengeDetail(challenge.id)
            }
        }
        controller.modalPresentationStyle = .pageSheet
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .large
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 26
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        present(controller, animated: true)
    }
}
