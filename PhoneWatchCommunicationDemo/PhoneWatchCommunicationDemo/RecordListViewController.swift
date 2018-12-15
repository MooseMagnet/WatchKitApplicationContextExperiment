import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var records: [String] = []
    
    @IBOutlet private weak var recordsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = _pubSub.sub(RecordListData.self) {
            self.updateTable($0.records)
        }
        
        let existingRecords = _applicationContextManager.getDataSharedAcrossDevices(RecordListData.self).records
        updateTable(existingRecords)
    }
    
    private func updateTable(_ newRecords: [String]) {
        records = newRecords
        DispatchQueue.main.async { [weak self] in
            self?.recordsTable.reloadData()
        }
    }
    
    private func publish() {
        _pubSub.pub(
            UpdateApplicationContextData(data:
                RecordListData(records: records, timestamp: Date().timeIntervalSince1970)))
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel!.text = records[indexPath.row]
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        records.remove(at: indexPath.row)
        publish()
    }
    
    // MARK: IB Actions
    
    @IBAction func Add() {
        let prompt = UIAlertController(title: "Type a thing", message: nil, preferredStyle: .alert)
        prompt.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let record = prompt.textFields!.first!.text else { return }
            prompt.dismiss(animated: true, completion: nil)
            self.records.append(record)
            self.publish()
        })
        prompt.addTextField(configurationHandler: nil)
        present(prompt, animated: true, completion: nil)
    }
    
    @IBAction func ClearAll() {
        records = []
        publish()
    }
}

