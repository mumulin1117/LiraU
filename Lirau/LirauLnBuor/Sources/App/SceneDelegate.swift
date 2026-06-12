import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.tintColor = LirauUserInterfaceLorauaTheme.interactiveLearningLorauaPrimary
        showInitialController()
        window.makeKeyAndVisible()
    }

  

    func showInitialController() {
        if LirauOnboardingFlowLorauaStore.shared.onboardingFlowLorauaIsLoggedIn {
            showMainInterface()
        } else {
            showWelcome()
        }
    }

    func showWelcome() {
        let welcomeController = LirauOnboardingFlowLorauaWelcomeViewController()
        welcomeController.onAuthenticated = { [weak self] in
            self?.showMainInterface()
        }
        let navigationController = UINavigationController(rootViewController: welcomeController)
        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = navigationController
    }

    func showMainInterface() {
        window?.rootViewController = LirauMainTabBarController()
    }
}
