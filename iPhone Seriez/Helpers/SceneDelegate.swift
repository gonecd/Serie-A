//import UIKit
//
//public class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//    public var window: UIWindow?
//
//    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        
//        // Configure the window if it doesn't exist yet
//        if window == nil {
//            window = UIWindow(windowScene: windowScene)
//        }
//        
//        // Handle URL context if app was launched via URL
//        if let urlContext = connectionOptions.urlContexts.first {
//            handleURL(urlContext.url)
//        }
//    }
//    
//    public func sceneDidBecomeActive(_ scene: UIScene) {
//        // Called when the scene has moved from an inactive state to an active state.
//        trakt.start()
//    }
//
//    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let urlContext = URLContexts.first else { return }
//        handleURL(urlContext.url)
//    }
//    
//    private func handleURL(_ url: URL) {
//        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
//        let source = components?.host
//        let params = components?.queryItems
//
//        print("<<<<< Dans le SceneDelegate >>>>")
//        print("Redirect URI from: \(String(describing: source))")
//        print("Full URL: \(url.absoluteString)")
//        print("Query params: \(String(describing: params))")
//
//        switch source {
//        case "Trakt":
//            // Récupérer le code d'autorisation depuis les query parameters
//            if let code = params?.first(where: { $0.name == "code" })?.value {
//                print("Authorization code received: \(code)")
//                trakt.downloadToken(key: code)
//            } else {
//                print("Error: No authorization code found in URL")
//            }
//        case "ASuivre1":
//            if let navigationController = window?.rootViewController as? UINavigationController {
//                navigationController.viewControllers.first?.performSegue(withIdentifier: "Go1", sender: nil)
//            }
//        case "ASuivre2":
//            if let navigationController = window?.rootViewController as? UINavigationController {
//                navigationController.viewControllers.first?.performSegue(withIdentifier: "Go2", sender: nil)
//            }
//        case "ASuivre3":
//            if let navigationController = window?.rootViewController as? UINavigationController {
//                navigationController.viewControllers.first?.performSegue(withIdentifier: "Go3", sender: nil)
//            }
//        default:
//            print("Unknown URL scheme host: \(String(describing: source))")
//            break
//        }
//    }
//}
