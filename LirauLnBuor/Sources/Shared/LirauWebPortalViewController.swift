import StoreKit
import UIKit
import WebKit

@objcMembers
final class LirauWebPortalViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    @objc var isModalTransition = false

    private let entryURLString: String
    private let bridgeMessageNames = [
        LirauCipherText.bridgePurchaseName(),
        LirauCipherText.bridgePurchaseSuccessName(),
        LirauCipherText.bridgeOpenPathName(),
        LirauCipherText.bridgeCloseName(),
        LirauCipherText.bridgeLogoutName()
    ]

    private var webView: WKWebView?
    private var activeProductID: String?
    private var productsRequest: SKProductsRequest?

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    @objc(initWithEntryURLString:)
    init(entryURLString: String) {
        self.entryURLString = entryURLString
        super.init(nibName: nil, bundle: nil)
        SKPaymentQueue.default().add(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        bridgeMessageNames.forEach { name in
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: name)
        }
        productsRequest?.cancel()
        SKPaymentQueue.default().remove(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        buildWebView()
        loadEntryURL()
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingIndicator.startAnimating()
    }

    private func buildWebView() {
        let webView = WKWebView(frame: .zero, configuration: makeConfiguration())
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
        self.webView = webView
    }

    private func makeConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        bridgeMessageNames.forEach { name in
            configuration.userContentController.add(LirauWeakScriptMessageHandler(delegate: self), name: name)
        }
        return configuration
    }

    private func loadEntryURL() {
        guard let url = URL(string: entryURLString) else {
            showPortalNotice("Invalid LiraU page.", isError: true)
            return
        }
        NSLog("LiraU Route Open WebPortal: %@", lirauDebugMaskedRoute(entryURLString))
        webView?.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            webView.isHidden = false
            self.loadingIndicator.stopAnimating()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showPortalNotice(error.localizedDescription, isError: true)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showPortalNotice(error.localizedDescription, isError: true)
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
        case LirauCipherText.bridgePurchaseName():
            guard let productID = message.body as? String else { return }
            startPurchase(productID)
        case LirauCipherText.bridgeOpenPathName():
            guard let nextPath = message.body as? String else { return }
            openNestedPortal(nextPath)
        case LirauCipherText.bridgeCloseName():
            closePortal()
        case LirauCipherText.bridgeLogoutName():
            logoutAndReturnToWelcome()
        default:
            break
        }
    }

    private func openNestedPortal(_ path: String) {
        NSLog("LiraU Route Open Nested WebPortal: %@", lirauDebugMaskedRoute(path))
        let controller = LirauWebPortalViewController(entryURLString: path)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    private func closePortal() {
        if isModalTransition {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func logoutAndReturnToWelcome() {
        LirauAuthStore.shared.sessionTokenLoraua = nil
        LirauAuthStore.shared.logout()
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.showWelcome()
            return
        }

        let welcomeController = LirauWelcomeViewController()
        welcomeController.onAuthenticated = { [weak self] in
            self?.view.window?.rootViewController = LirauMainTabBarController()
        }
        let navigationController = UINavigationController(rootViewController: welcomeController)
        navigationController.setNavigationBarHidden(true, animated: false)
        view.window?.rootViewController = navigationController
        view.window?.makeKeyAndVisible()
    }

    private func startPurchase(_ productID: String) {
        guard SKPaymentQueue.canMakePayments() else {
            showPortalNotice("In-app purchases are unavailable.", isError: true)
            return
        }
        view.isUserInteractionEnabled = false
        loadingIndicator.startAnimating()
        activeProductID = productID
        let request = SKProductsRequest(productIdentifiers: Set([productID]))
        request.delegate = self
        productsRequest = request
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handleProductsResponse(response)
            }
            return
        }
        handleProductsResponse(response)
    }

    private func handleProductsResponse(_ response: SKProductsResponse) {
        productsRequest = nil
        guard let product = response.products.first else {
            showPortalNotice("Product is unavailable.", isError: true)
            return
        }
        SKPaymentQueue.default().add(SKPayment(product: product))
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handleProductsRequestFailure(error)
            }
            return
        }
        handleProductsRequestFailure(error)
    }

    private func handleProductsRequestFailure(_ error: Error) {
        productsRequest = nil
        showPortalNotice(error.localizedDescription, isError: true)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.handlePaymentTransactions(transactions)
            }
            return
        }
        handlePaymentTransactions(transactions)
    }

    private func handlePaymentTransactions(_ transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                finishSuccessfulPurchase()
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                showPortalNotice(transaction.error?.localizedDescription ?? "Payment failed.", isError: true)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                finishSuccessfulPurchase()
            default:
                break
            }
        }
    }

    private func finishSuccessfulPurchase() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.finishSuccessfulPurchase()
            }
            return
        }
        webView?.evaluateJavaScript("\(LirauCipherText.bridgePurchaseSuccessName())()", completionHandler: nil)
        showPortalNotice("Payment successful.", isError: false)
    }

    private func showPortalNotice(_ message: String, isError: Bool) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.showPortalNotice(message, isError: isError)
            }
            return
        }
        view.isUserInteractionEnabled = true
        loadingIndicator.stopAnimating()
        guard isError, view.window != nil else { return }
        let alert = UIAlertController(title: "LiraU", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

@objcMembers
final class LirauWebRoute: NSObject {
    private static let appID = LirauCipherText.appKey()
    private static let baseHashURL = LirauCipherText.webBaseHashURL()

    @objc static func languageAIMentorPath() -> String {
        makePath(LirauCipherText.webAIExpertPath(), queryItems: [])
    }

    @objc static func communityHubPath() -> String {
        makePath(LirauCipherText.webRepositoryPath(), queryItems: [URLQueryItem(name: LirauCipherText.queryCurrentKey(), value: "0")])
    }

    @objc(repositoryPathWithCurrentIndex:)
    static func repositoryPath(currentIndex: Int) -> String {
        let boundedIndex = max(0, min(currentIndex, 2))
        return makePath(LirauCipherText.webRepositoryPath(), queryItems: [URLQueryItem(name: LirauCipherText.queryCurrentKey(), value: "\(boundedIndex)")])
    }

    @objc(dynamicDetailPathWithDynamicID:)
    static func dynamicDetailPath(dynamicID: String) -> String {
        makePath(LirauCipherText.webDynamicDetailPath(), queryItems: [URLQueryItem(name: LirauCipherText.queryDynamicIDKey(), value: dynamicID)])
    }

    @objc static func postArticlePath() -> String {
        makePath(LirauCipherText.webPostArticlePath(), queryItems: [])
    }

    @objc static func postVideoPath() -> String {
        makePath(LirauCipherText.webPostVideoPath(), queryItems: [])
    }

    @objc(learnerProfilePathWithUserID:)
    static func learnerProfilePath(userID: String) -> String {
        makePath(LirauCipherText.webLearnerProfilePath(), queryItems: [URLQueryItem(name: LirauCipherText.queryUserIDKey(), value: userID)])
    }

    @objc(reportPathWithDynamicID:userID:)
    static func reportPath(dynamicID: String, userID: String) -> String {
        var items: [URLQueryItem] = []
        if !dynamicID.isEmpty {
            items.append(URLQueryItem(name: LirauCipherText.queryDynamicIDKey(), value: dynamicID))
        }
        if !userID.isEmpty {
            items.append(URLQueryItem(name: LirauCipherText.queryUserIDKey(), value: userID))
        }
        return makePath(LirauCipherText.webReportPath(), queryItems: items)
    }

    @objc static func messagesPath() -> String {
        makePath(LirauCipherText.webMessagesPath(), queryItems: [])
    }

    @objc static func editProfilePath() -> String {
        makePath(LirauCipherText.webEditProfilePath(), queryItems: [])
    }

    @objc(relationListPathWithType:)
    static func relationListPath(type: Int) -> String {
        makePath(LirauCipherText.webRelationListPath(), queryItems: [URLQueryItem(name: LirauCipherText.queryTypeKey(), value: "\(type)")])
    }

    @objc static func walletPath() -> String {
        makePath(LirauCipherText.webWalletPath(), queryItems: [])
    }

    @objc static func settingsPath() -> String {
        makePath(LirauCipherText.webSettingsPath(), queryItems: [])
    }

    @objc static func userAgreementPath() -> String {
        makePath(LirauCipherText.webAgreementPath(), queryItems: [URLQueryItem(name: LirauCipherText.queryTypeKey(), value: "1")])
    }

    @objc static func privacyPolicyPath() -> String {
        makePath(LirauCipherText.webAgreementPath(), queryItems: [URLQueryItem(name: LirauCipherText.queryTypeKey(), value: "2")])
    }

    @objc(privateChatPathWithUserID:callVideo:)
    static func privateChatPath(userID: String, callVideo: Bool) -> String {
        var items = [URLQueryItem(name: LirauCipherText.queryUserIDKey(), value: userID)]
        if callVideo {
            items.append(URLQueryItem(name: LirauCipherText.queryCallVideoKey(), value: "1"))
        }
        return makePath(LirauCipherText.webPrivateChatPath(), queryItems: items)
    }

    private static func makePath(_ route: String, queryItems: [URLQueryItem]) -> String {
        var items = queryItems.filter { !($0.value ?? "").isEmpty }
        items.append(URLQueryItem(name: LirauCipherText.tokenHeader(), value: LirauAuthStore.shared.sessionTokenLoraua ?? ""))
        items.append(URLQueryItem(name: LirauCipherText.queryAppIDKey(), value: appID))

        var components = URLComponents()
        components.queryItems = items
        let query = components.percentEncodedQuery ?? ""
        let finalPath = baseHashURL + route + (query.isEmpty ? "" : "?\(query)")
        NSLog("LiraU Route Build: route=%@ final=%@", route, lirauDebugMaskedRoute(finalPath))
        return finalPath
    }
}

fileprivate func lirauDebugMaskedRoute(_ path: String) -> String {
    guard var components = URLComponents(string: path),
          let queryItems = components.queryItems else {
        return path
    }
    components.queryItems = queryItems.map { item in
        if item.name.lowercased() == LirauCipherText.tokenHeader(), let value = item.value, !value.isEmpty {
            return URLQueryItem(name: item.name, value: "\(value.prefix(4))...\(value.suffix(4))")
        }
        return item
    }
    return components.string ?? path
}

private final class LirauWeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
