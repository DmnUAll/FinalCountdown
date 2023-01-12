import UIKit

// MARK: - NavigationController
final class NavigationController: UINavigationController {

    // MARK: - Properties and Initializers
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configureNavigationController()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
extension NavigationController {

    private func configureNavigationController() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.tintColor = .fcGrayLight
        let addEventButton = UIBarButtonItem(systemItem: .add, primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.pushViewController(EventController(), animated: true)
        }))
        navigationBar.topItem?.rightBarButtonItem = addEventButton
    }
}
