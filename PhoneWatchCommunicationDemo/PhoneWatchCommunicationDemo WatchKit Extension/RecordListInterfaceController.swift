import WatchKit

class RecordListInterfaceController: WKInterfaceController {

    private var records: [String] = []
    
    @IBOutlet private weak var recordsTable: WKInterfaceTable!
    @IBOutlet private weak var noRecordsLabel: WKInterfaceLabel!
    
    private var unsub: (() -> Void)!
    
    override func willActivate() {
        super.willActivate()
        
        unsub = _pubSub.sub(RecordListData.self) {
            self.updateTable($0.records)
        }
        
        let existingRecords = _applicationContextManager.getDataSharedAcrossDevices(RecordListData.self).records
        updateTable(existingRecords)
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        unsub()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        records.remove(at: rowIndex)
        publish()
    }
    
    private func updateTable(_ newRecords: [String]) {
        noRecordsLabel.setHidden(newRecords.count > 0)
        records = newRecords
        recordsTable.setNumberOfRows(records.count, withRowType: "RecordRowController")
        (0..<records.count).forEach {
            let row = recordsTable.rowController(at: $0) as! RecordRowController
            row.bind(records[$0])
        }
    }
    
    private func publish() {
        _pubSub.pub(
            UpdateApplicationContextData(data:
                RecordListData(records: records, timestamp: Date().timeIntervalSince1970)))
    }
    
    // MARK: IB Actions
    
    @IBAction func clearAll() {
        records.removeAll()
        publish()
    }
    
    @IBAction func add() {
        presentTextInputController(withSuggestions: nil, allowedInputMode: .allowEmoji) {
            guard let record = $0?[0] as? String else { return }
            self.records.append(record)
            self.publish()
            self.dismissTextInputController()
        }
    }
}

class RecordRowController : NSObject {
    @IBOutlet private weak var label: WKInterfaceLabel!
    
    func bind(_ record: String) {
        label.setText(record)
    }
}
