import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    for context in connectionOptions.urlContexts {
      OpenedEpubRelay.shared.handle(url: context.url)
    }
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    var forwarded = Set<UIOpenURLContext>()
    for context in URLContexts {
      if !OpenedEpubRelay.shared.handle(url: context.url) {
        forwarded.insert(context)
      }
    }
    if !forwarded.isEmpty {
      super.scene(scene, openURLContexts: forwarded)
    }
  }
}
