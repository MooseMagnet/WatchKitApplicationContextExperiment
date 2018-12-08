import WatchKit

class InterfaceController: WKInterfaceController {

    private var records: [String] = []
    
    @IBOutlet private weak var recordsTable: WKInterfaceTable!
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        records.remove(at: rowIndex)
        updateTable()
    }
    
    private func updateTable() {
        recordsTable.setNumberOfRows(records.count, withRowType: "RecordRowController")
        (0..<records.count).forEach {
            let row = recordsTable.rowController(at: $0) as! RecordRowController
            row.bind(records[$0])
        }
    }
    
    // MARK: IB Actions
    
    @IBAction func clearAll() {
        records.removeAll()
        updateTable()
    }
    
    @IBAction func add() {
        presentTextInputController(withSuggestions: nil, allowedInputMode: .allowEmoji) {
            guard let record = $0?[0] as? String else { return }
            self.records.append(record)
            self.updateTable()
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
