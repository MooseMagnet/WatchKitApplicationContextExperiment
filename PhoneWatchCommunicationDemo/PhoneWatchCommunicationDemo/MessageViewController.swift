import UIKit

class MessageViewController : UIViewController {
    
    @IBOutlet private weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = _pubSub.sub(MessageFromWatchData.self) {
            self.setMessageFromWatch($0.message)
        }
        
        let existingMessage = _applicationContextManager.getDataSharedAcrossDevices(MessageFromWatchData.self).message
        setMessageFromWatch(existingMessage)
    }
    
    private func setMessageFromWatch(_ message: String) {
        if message.count > 0 {
            DispatchQueue.main.async {
                self.messageLabel.text = message
            }
        }
    }
    
    // MARK: IB Actions
    
    @IBAction func sendMessage() {
        let prompt = UIAlertController(title: "Type a message", message: nil, preferredStyle: .alert)
        prompt.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let message = prompt.textFields!.first!.text else { return }
            prompt.dismiss(animated: true, completion: nil)
            _pubSub.pub(
                UpdateApplicationContextData(data:
                    MessageFromPhoneData(message: message, timestamp: Date().timeIntervalSince1970)))
        })
        prompt.addTextField(configurationHandler: nil)
        present(prompt, animated: true, completion: nil)
    }
}
