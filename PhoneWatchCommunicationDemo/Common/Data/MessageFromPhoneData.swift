struct MessageFromPhoneData : ApplicationContextDataType {
    let message: String
    let timestamp: Double
    
    static func empty(_ timestamp: Double) -> MessageFromPhoneData {
        return MessageFromPhoneData(message: "", timestamp: timestamp)
    }
}
