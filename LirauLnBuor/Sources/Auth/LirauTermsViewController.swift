import UIKit

final class LirauTermsViewController: UIViewController {
    enum Kind {
        case privacy
        case terms
    }

    private let kind: Kind

    init(kind: Kind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LirauTheme.background
        title = kind == .privacy ? "Privacy Policy" : "Terms"
        setupLayout()
    }

    private func setupLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let label = UILabel()
        label.font = LirauTheme.bodyFont(15)
        label.textColor = LirauTheme.text
        label.numberOfLines = 0
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(label)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            label.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 20),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 24)
        ])
    }

    private var text: String {
        switch kind {
        case .privacy:
            return """
            LiraU keeps account information local in this starter build and uses permissions only when a user chooses a related feature.

            Camera, microphone, photo library, and location permissions are requested only for language practice, cultural video snippets, profile media, or partner relevance. LiraU does not present itself as an anonymous or adult chat service.
            """
        case .terms:
            return """
            LiraU is for respectful language learning and cultural exchange. This service is not a random, anonymous, adult, or suggestive chat service.

            Users must meet account requirements, follow local age and identity rules, avoid harmful content, and use report or block tools when needed. Violations may lead to content removal or account restrictions.
            """
        }
    }
}
