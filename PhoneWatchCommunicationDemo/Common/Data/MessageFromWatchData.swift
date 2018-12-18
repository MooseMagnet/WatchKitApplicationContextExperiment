// NOTE: It's probably not a good idea to rely on ApplicationContext for messaging.
// This is just an example.

struct MessageFromWatchData : ApplicationContextDataType {
    let message: String
    let timestamp: Double
    
    static func empty(_ timestamp: Double) -> MessageFromWatchData {
        return MessageFromWatchData(message: "", timestamp: timestamp)
    }
}
