import FirebaseAuth
import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  /// URL schemes registered in Info.plist (CFBundleURLSchemes).
  /// Firebase Auth callback URLs use these schemes.
  private lazy var registeredURLSchemes: Set<String> = {
    guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else {
      return []
    }
    var schemes = Set<String>()
    for urlType in urlTypes {
      if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String] {
        schemes.formUnion(urlSchemes)
      }
    }
    return schemes
  }()

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    for urlContext in URLContexts {
      let url = urlContext.url

      // Let Firebase Auth handle the URL if it can.
      if Auth.auth().canHandle(url) {
        return
      }

      // Firebase Auth callback URLs use the custom URL scheme registered in Info.plist.
      // These are intermediate redirects (via Firebase Dynamic Links) and should not
      // be forwarded to the Flutter Navigator, as signInWithProvider handles auth
      // internally via ASWebAuthenticationSession.
      if let scheme = url.scheme, registeredURLSchemes.contains(scheme) {
        return
      }
    }
    super.scene(scene, openURLContexts: URLContexts)
  }
}
