import StoreKit
import UIKit
import WebKit

@objcMembers
final class LirauDeepLinkingLorauaPortalViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    @objc var deepLinkingLorauaIsModalTransition = false

    private let deepLinkingLorauaEntryURLString: String
    private let interactiveDialogueLorauaBridgeMessageNames = [
        LirauEncryptionLorauaText.inAppPurchaseLorauaBridgeName(),
        LirauEncryptionLorauaText.inAppPurchaseLorauaSuccessBridgeName(),
        LirauEncryptionLorauaText.deepLinkingLorauaOpenPathBridgeName(),
        LirauEncryptionLorauaText.deepLinkingLorauaCloseBridgeName(),
        LirauEncryptionLorauaText.onboardingFlowLorauaLogoutBridgeName()
    ]

    private var deepLinkingLorauaWebView: WKWebView?
    private var inAppPurchaseLorauaActiveProductID: String?
    private var inAppPurchaseLorauaProductsRequest: SKProductsRequest?

    private lazy var userExperienceLorauaLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    @objc(initWithDeepLinkingLorauaEntryURLString:)
    init(deepLinkingLorauaEntryURLString: String) {
        self.deepLinkingLorauaEntryURLString = deepLinkingLorauaEntryURLString
        super.init(nibName: nil, bundle: nil)
        SKPaymentQueue.default().add(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        interactiveDialogueLorauaBridgeMessageNames.forEach { name in
            deepLinkingLorauaWebView?.configuration.userContentController.removeScriptMessageHandler(forName: name)
        }
        inAppPurchaseLorauaProductsRequest?.cancel()
        SKPaymentQueue.default().remove(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        buildDeepLinkingLorauaWebView()
        loadDeepLinkingLorauaEntryURL()
        view.addSubview(userExperienceLorauaLoadingIndicator)
        NSLayoutConstraint.activate([
            userExperienceLorauaLoadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userExperienceLorauaLoadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        userExperienceLorauaLoadingIndicator.startAnimating()
    }

    private func buildDeepLinkingLorauaWebView() {
        let webView = WKWebView(frame: .zero, configuration: makeInteractiveDialogueLorauaConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.isHidden = true
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        deepLinkingLorauaWebView = webView
    }

    private func makeInteractiveDialogueLorauaConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        interactiveDialogueLorauaBridgeMessageNames.forEach { name in
            configuration.userContentController.add(LirauInteractiveDialogueLorauaScriptHandler(delegate: self), name: name)
        }
        return configuration
    }

    private func loadDeepLinkingLorauaEntryURL() {
        guard let url = URL(string: deepLinkingLorauaEntryURLString) else {
            showDeepLinkingLorauaNotice("Invalid LiraU page.", isError: true)
            return
        }
        NSLog("LiraU Route Open WebPortal: %@", lirauDataPrivacyLorauaMaskedRoute(deepLinkingLorauaEntryURLString))
        deepLinkingLorauaWebView?.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            webView.isHidden = false
            self.userExperienceLorauaLoadingIndicator.stopAnimating()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showDeepLinkingLorauaNotice(error.localizedDescription, isError: true)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showDeepLinkingLorauaNotice(error.localizedDescription, isError: true)
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case LirauEncryptionLorauaText.inAppPurchaseLorauaBridgeName():
            guard let productID = message.body as? String else { return }
            startInAppPurchaseLoraua(productID)
        case LirauEncryptionLorauaText.deepLinkingLorauaOpenPathBridgeName():
            guard let nextPath = message.body as? String else { return }
            openDeepLinkingLorauaNestedPortal(nextPath)
        case LirauEncryptionLorauaText.deepLinkingLorauaCloseBridgeName():
            closeDeepLinkingLorauaPortal()
        case LirauEncryptionLorauaText.onboardingFlowLorauaLogoutBridgeName():
            logoutOnboardingFlowLoraua()
        default:
            break
        }
    }

    private func openDeepLinkingLorauaNestedPortal(_ path: String) {
        NSLog("LiraU Route Open Nested WebPortal: %@", lirauDataPrivacyLorauaMaskedRoute(path))
        let controller = LirauDeepLinkingLorauaPortalViewController(deepLinkingLorauaEntryURLString: path)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    private func closeDeepLinkingLorauaPortal() {
        if deepLinkingLorauaIsModalTransition {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func logoutOnboardingFlowLoraua() {
        LirauOnboardingFlowLorauaStore.shared.sessionTokenLoraua = nil
        LirauOnboardingFlowLorauaStore.shared.onboardingFlowLorauaLogout()
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.showWelcome()
            return
        }

        let welcomeController = LirauOnboardingFlowLorauaWelcomeViewController()
        welcomeController.onAuthenticated = { [weak self] in
            self?.view.window?.rootViewController = LirauMainTabBarController()
        }
        let navigationController = UINavigationController(rootViewController: welcomeController)
        navigationController.setNavigationBarHidden(true, animated: false)
        view.window?.rootViewController = navigationController
        view.window?.makeKeyAndVisible()
    }

    private func startInAppPurchaseLoraua(_ productID: String) {
        guard SKPaymentQueue.canMakePayments() else {
            showDeepLinkingLorauaNotice("In-app purchases are unavailable.", isError: true)
            return
        }
        view.isUserInteractionEnabled = false
        userExperienceLorauaLoadingIndicator.startAnimating()
        inAppPurchaseLorauaActiveProductID = productID
        let request = SKProductsRequest(productIdentifiers: Set([productID]))
        request.delegate = self
        inAppPurchaseLorauaProductsRequest = request
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handleInAppPurchaseLorauaProductsResponse(response)
            }
            return
        }
        handleInAppPurchaseLorauaProductsResponse(response)
    }

    private func handleInAppPurchaseLorauaProductsResponse(_ response: SKProductsResponse) {
        inAppPurchaseLorauaProductsRequest = nil
        guard let product = response.products.first else {
            showDeepLinkingLorauaNotice("Product is unavailable.", isError: true)
            return
        }
        SKPaymentQueue.default().add(SKPayment(product: product))
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handleInAppPurchaseLorauaRequestFailure(error)
            }
            return
        }
        handleInAppPurchaseLorauaRequestFailure(error)
    }

    private func handleInAppPurchaseLorauaRequestFailure(_ error: Error) {
        inAppPurchaseLorauaProductsRequest = nil
        showDeepLinkingLorauaNotice(error.localizedDescription, isError: true)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handleInAppPurchaseLorauaTransactions(transactions)
            }
            return
        }
        handleInAppPurchaseLorauaTransactions(transactions)
    }

    private func handleInAppPurchaseLorauaTransactions(_ transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                finishInAppPurchaseLorauaSuccess()
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                showDeepLinkingLorauaNotice(transaction.error?.localizedDescription ?? "Payment failed.", isError: true)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                finishInAppPurchaseLorauaSuccess()
            default:
                break
            }
        }
    }

    private func finishInAppPurchaseLorauaSuccess() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.finishInAppPurchaseLorauaSuccess()
            }
            return
        }
        deepLinkingLorauaWebView?.evaluateJavaScript("\(LirauEncryptionLorauaText.inAppPurchaseLorauaSuccessBridgeName())()", completionHandler: nil)
        showDeepLinkingLorauaNotice("Payment successful.", isError: false)
    }

    private func showDeepLinkingLorauaNotice(_ message: String, isError: Bool) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.showDeepLinkingLorauaNotice(message, isError: isError)
            }
            return
        }
        view.isUserInteractionEnabled = true
        userExperienceLorauaLoadingIndicator.stopAnimating()
        guard isError, view.window != nil else { return }
        let alert = UIAlertController(title: "LiraU", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

@objcMembers
final class LirauDeepLinkingLorauaRoute: NSObject {
    private static let appIndexingLorauaAppID = LirauEncryptionLorauaText.appIndexingLorauaAppKey()
    private static let deepLinkingLorauaBaseHashURL = LirauEncryptionLorauaText.deepLinkingLorauaBaseHashURL()

    @objc static func languageMentorshipLorauaAIPath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.languageMentorshipLorauaAIExpertPath(), queryItems: [])
    }

    @objc static func communityHubLorauaPath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.linguisticHeritageLorauaRepositoryPath(), queryItems: [URLQueryItem(name: LirauEncryptionLorauaText.linguisticHeritageLorauaQueryCurrentKey(), value: "0")])
    }

    @objc(linguisticHeritageLorauaRepositoryPathWithCurrentIndex:)
    static func linguisticHeritageLorauaRepositoryPath(currentIndex: Int) -> String {
        let boundedIndex = max(0, min(currentIndex, 2))
        return deepLinkingLorauaMakePath(LirauEncryptionLorauaText.linguisticHeritageLorauaRepositoryPath(), queryItems: [URLQueryItem(name: LirauEncryptionLorauaText.linguisticHeritageLorauaQueryCurrentKey(), value: "\(boundedIndex)")])
    }

    @objc(narrativeSharingLorauaDynamicDetailPathWithDynamicID:)
    static func narrativeSharingLorauaDynamicDetailPath(dynamicID: String) -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.narrativeSharingLorauaDynamicDetailPath(), queryItems: [URLQueryItem(name: LirauEncryptionLorauaText.narrativeSharingLorauaQueryDynamicIDKey(), value: dynamicID)])
    }

    @objc static func narrativeSharingLorauaPostArticlePath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.narrativeSharingLorauaPostArticlePath(), queryItems: [])
    }

    @objc static func videoSnippetLorauaPostVideoPath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.videoSnippetLorauaPostVideoPath(), queryItems: [])
    }

    @objc(languageExchangePartnerLorauaProfilePathWithUserID:)
    static func languageExchangePartnerLorauaProfilePath(userID: String) -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.languageExchangePartnerLorauaProfilePath(), queryItems: [URLQueryItem(name: LirauEncryptionLorauaText.languageExchangePartnerLorauaQueryUserIDKey(), value: userID)])
    }

    @objc(reportSystemLorauaPathWithDynamicID:userID:)
    static func reportSystemLorauaPath(dynamicID: String, userID: String) -> String {
        var items: [URLQueryItem] = []
        if !dynamicID.isEmpty {
            items.append(URLQueryItem(name: LirauEncryptionLorauaText.narrativeSharingLorauaQueryDynamicIDKey(), value: dynamicID))
        }
        if !userID.isEmpty {
            items.append(URLQueryItem(name: LirauEncryptionLorauaText.languageExchangePartnerLorauaQueryUserIDKey(), value: userID))
        }
        return deepLinkingLorauaMakePath(LirauEncryptionLorauaText.reportSystemLorauaWebPath(), queryItems: items)
    }

    @objc static func notificationSettingLorauaMessagesPath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.notificationSettingLorauaMessagesPath(), queryItems: [])
    }

    @objc static func profileIntroLorauaEditPath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.profileIntroLorauaEditPath(), queryItems: [])
    }

    @objc(globalCommunityLorauaRelationListPathWithType:)
    static func globalCommunityLorauaRelationListPath(type: Int) -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.globalCommunityLorauaRelationListPath(), queryItems: [URLQueryItem(name: LirauEncryptionLorauaText.userAgreementLorauaQueryTypeKey(), value: "\(type)")])
    }

    @objc static func virtualCurrencyLorauaWalletPath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.virtualCurrencyLorauaWalletPath(), queryItems: [])
    }

    @objc static func privacySettingsLorauaSettingsPath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.privacySettingsLorauaSettingsPath(), queryItems: [])
    }

    @objc static func userAgreementLorauaPath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.userAgreementLorauaWebPath(), queryItems: [URLQueryItem(name: LirauEncryptionLorauaText.userAgreementLorauaQueryTypeKey(), value: "1")])
    }

    @objc static func privacyPolicyLorauaPath() -> String {
        deepLinkingLorauaMakePath(LirauEncryptionLorauaText.userAgreementLorauaWebPath(), queryItems: [URLQueryItem(name: LirauEncryptionLorauaText.userAgreementLorauaQueryTypeKey(), value: "2")])
    }

    @objc(interactiveDialogueLorauaPrivateChatPathWithUserID:callVideo:)
    static func interactiveDialogueLorauaPrivateChatPath(userID: String, callVideo: Bool) -> String {
        var items = [URLQueryItem(name: LirauEncryptionLorauaText.languageExchangePartnerLorauaQueryUserIDKey(), value: userID)]
        if callVideo {
            items.append(URLQueryItem(name: LirauEncryptionLorauaText.videoFrameLorauaQueryCallVideoKey(), value: "1"))
        }
        return deepLinkingLorauaMakePath(LirauEncryptionLorauaText.interactiveDialogueLorauaPrivateChatPath(), queryItems: items)
    }

    private static func deepLinkingLorauaMakePath(_ route: String, queryItems: [URLQueryItem]) -> String {
        var items = queryItems.filter { !($0.value ?? "").isEmpty }
        items.append(URLQueryItem(name: LirauEncryptionLorauaText.pointSystemLorauaTokenHeader(), value: LirauOnboardingFlowLorauaStore.shared.sessionTokenLoraua ?? ""))
        items.append(URLQueryItem(name: LirauEncryptionLorauaText.appIndexingLorauaQueryAppIDKey(), value: appIndexingLorauaAppID))

        var components = URLComponents()
        components.queryItems = items
        let query = components.percentEncodedQuery ?? ""
        let finalPath = deepLinkingLorauaBaseHashURL + route + (query.isEmpty ? "" : "?\(query)")
        NSLog("LiraU Route Build: route=%@ final=%@", route, lirauDataPrivacyLorauaMaskedRoute(finalPath))
        return finalPath
    }
}

fileprivate func lirauDataPrivacyLorauaMaskedRoute(_ path: String) -> String {
    guard var components = URLComponents(string: path),
          let queryItems = components.queryItems else {
        return path
    }
    components.queryItems = queryItems.map { item in
        if item.name.lowercased() == LirauEncryptionLorauaText.pointSystemLorauaTokenHeader(), let value = item.value, !value.isEmpty {
            return URLQueryItem(name: item.name, value: "\(value.prefix(4))...\(value.suffix(4))")
        }
        return item
    }
    return components.string ?? path
}

private final class LirauInteractiveDialogueLorauaScriptHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
