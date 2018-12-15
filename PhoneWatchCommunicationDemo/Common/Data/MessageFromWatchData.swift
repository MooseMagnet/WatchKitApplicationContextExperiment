struct MessageFromWatchData : ApplicationContextDataType {
    let message: String
    let timestamp: Double
    
    static func empty(_ timestamp: Double) -> MessageFromWatchData {
        return MessageFromWatchData(message: "", timestamp: timestamp)
    }
}
