struct RecordListData : ApplicationContextDataType {
    let records: [String]
    let timestamp: Double
    
    static func empty(_ timestamp: Double) -> RecordListData {
        return RecordListData(records: [], timestamp: timestamp)
    }
}
