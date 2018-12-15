import WatchKit

class MessageInterfaceController: WKInterfaceController {

    private var unsub: (() -> Void)!
    
    @IBOutlet private weak var messageLabel: WKInterfaceLabel!
    
    override func willActivate() {
        super.willActivate()
        unsub = _pubSub.sub(MessageFromPhoneData.self) {
            self.setMessageFromPhone($0.message)
        }
        
        let existingMessage = _applicationContextManager.getDataSharedAcrossDevices(MessageFromPhoneData.self).message
        setMessageFromPhone(existingMessage)
    }
    
    private func setMessageFromPhone(_ message: String) {
        if message.count > 0 {
            messageLabel.setText(message)
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        unsub()
    }
    
    // MARK: IB Actions
    
    @IBAction func sendMessage() {
        presentTextInputController(withSuggestions: nil, allowedInputMode: .allowEmoji) {
            guard let message = $0?[0] as? String else { return }
            _pubSub.pub(
                UpdateApplicationContextData(data:
                    MessageFromWatchData(message: message, timestamp: Date().timeIntervalSince1970)))
            self.dismissTextInputController()
        }
    }

}
