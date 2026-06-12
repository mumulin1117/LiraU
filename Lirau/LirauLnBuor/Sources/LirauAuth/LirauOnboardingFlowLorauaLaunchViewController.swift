import UIKit

final class LirauOnboardingFlowLorauaLaunchViewController: UIViewController {
    var onFinished: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.onFinished?()
        }
    }

    private func setupLayout() {
        let backdropView = LirauOnboardingFlowLorauaBackdropView(imageName: "lira_launch_bg_books")
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdropView)

        let logoView = UIImageView(image: UIImage(named: "lira_logo_chat"))
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -74),
            logoView.widthAnchor.constraint(equalToConstant: 90),
            logoView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}
