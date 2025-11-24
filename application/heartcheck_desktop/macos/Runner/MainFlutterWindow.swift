import Cocoa
import FlutterMacOS
import Sparkle

class MainFlutterWindow: NSWindow {
    
    let updaterController: SPUStandardUpdaterController =
    {
        let controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        
        return controller
    }()

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
    updaterController.updater.checkForUpdatesInBackground()
  }
}
