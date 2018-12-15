import WatchKit

class MainMenuInterfaceController : WKInterfaceController {
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        _bootstrapper.go()
    }
}
