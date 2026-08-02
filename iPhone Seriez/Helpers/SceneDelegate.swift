import UIKit

public class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    public var window: UIWindow?

    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        let url = urlContext.url
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        let source = components?.host
        let params = components?.queryItems

        print("Redirect URI from :\(String(describing: source))")

        switch source {
        case "Trakt":
            trakt.downloadToken(key: params?.first?.value ?? "")
        case "ASuivre1":
            if let navigationController = window?.rootViewController as? UINavigationController {
                navigationController.viewControllers.first?.performSegue(withIdentifier: "Go1", sender: nil)
            }
        case "ASuivre2":
            if let navigationController = window?.rootViewController as? UINavigationController {
                navigationController.viewControllers.first?.performSegue(withIdentifier: "Go2", sender: nil)
            }
        case "ASuivre3":
            if let navigationController = window?.rootViewController as? UINavigationController {
                navigationController.viewControllers.first?.performSegue(withIdentifier: "Go3", sender: nil)
            }
        default:
            break
        }
    }
}
