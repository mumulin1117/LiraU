import UIKit

final class LirauMainTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        setValue(LirauLanhuTabBar(), forKey: "tabBar")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarAppearance()
        viewControllers = [
            makeNavigationController(
                root: LirauHomeViewController(),
                title: "Home",
                normalIcon: "lira_tab_home_normal",
                selectedIcon: "lira_tab_home_selected"
            ),
            makeNavigationController(
                root: LirauCommunityViewController(),
                title: "Community",
                normalIcon: "lira_tab_community_normal",
                selectedIcon: "lira_tab_community_selected"
            ),
            makeNavigationController(
                root: LirauVideoViewController(),
                title: "Video",
                normalIcon: "lira_tab_video_normal",
                selectedIcon: "lira_tab_video_selected"
            ),
            makeNavigationController(
                root: LirauProfileViewController(),
                title: "Me",
                normalIcon: "lira_tab_profile_normal",
                selectedIcon: "lira_tab_profile_selected"
            )
        ]
    }

    private func configureTabBarAppearance() {
        tabBar.tintColor = nil
        tabBar.unselectedItemTintColor = nil
        tabBar.isTranslucent = false
        tabBar.itemPositioning = .fill
        tabBar.backgroundColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.stackedLayoutAppearance.normal.iconColor = nil
        appearance.stackedLayoutAppearance.selected.iconColor = nil
        appearance.inlineLayoutAppearance.normal.iconColor = nil
        appearance.inlineLayoutAppearance.selected.iconColor = nil
        appearance.compactInlineLayoutAppearance.normal.iconColor = nil
        appearance.compactInlineLayoutAppearance.selected.iconColor = nil
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func makeNavigationController(
        root: UIViewController,
        title: String,
        normalIcon: String,
        selectedIcon: String
    ) -> UINavigationController {
        root.title = nil
        let normalImage = UIImage(named: normalIcon)?.withRenderingMode(.alwaysOriginal)
        let selectedImage = UIImage(named: selectedIcon)?.withRenderingMode(.alwaysOriginal)
        root.tabBarItem = UITabBarItem(title: nil, image: normalImage, selectedImage: selectedImage)
        root.tabBarItem.accessibilityLabel = title
        root.tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }
}

private final class LirauLanhuTabBar: UITabBar {
    private let backgroundView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var fittedSize = super.sizeThatFits(size)
        let bottomInset = window?.safeAreaInsets.bottom ?? 0
        fittedSize.height = 51 + bottomInset
        return fittedSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        sendSubviewToBack(backgroundView)
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = 18
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let itemHeight: CGFloat = 51
        let itemWidth = bounds.width / CGFloat(max(items?.count ?? 1, 1))
        var index: CGFloat = 0
        subviews
            .filter { String(describing: type(of: $0)).contains("UITabBarButton") }
            .sorted { $0.frame.minX < $1.frame.minX }
            .forEach { itemView in
                itemView.frame = CGRect(x: index * itemWidth, y: 0, width: itemWidth, height: itemHeight)
                index += 1
            }
    }

    private func setupBackground() {
        isTranslucent = false
        backgroundColor = .clear
        backgroundImage = UIImage()
        shadowImage = UIImage()

        backgroundView.isUserInteractionEnabled = false
        backgroundView.backgroundColor = UIColor(red: 0.114, green: 0.106, blue: 0.18, alpha: 1)
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.24
        backgroundView.layer.shadowRadius = 18
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: -8)
        insertSubview(backgroundView, at: 0)
    }
}
