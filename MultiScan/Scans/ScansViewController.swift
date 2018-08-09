//
//  ViewController.swift
//  MultiScan
//
//  Created by Chris Woodard on 6/19/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import UIKit
import sqlite3
import CSV
import Toast_Swift

let maxNumberOfScans = 100

class ScansViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScanValueDelegate {

    @IBOutlet weak var noScansView: UIView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    var cache:ScansCache? = nil
    var scans:[[String:Any]] = []
    var selectModeIsActive:Bool = false
    var selectedIds:Set<Int64> = Set<Int64>()
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    @IBOutlet weak var helpOverlay: UIView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var trashCanBarButton: UIBarButtonItem!
    
    @IBAction func showHelpOverlay(_ sender: Any) {
        self.view.bringSubview(toFront: self.helpOverlay)
        self.helpOverlay.isHidden = false
    }
    
    @IBAction func deleteSelectedScans(_ sender: Any) {
        let alert = UIAlertController(title: "Warning", message: "This will delete the selected scans. This action cannot be undone.  Are you sure you want to do this?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {action in
            DispatchQueue(label: "Yo").async {
                let db = self.cache?.openDb()
                _ = self.cache?.removeScans(db: db, withIds: self.selectedIds)
                self.cache?.closeDb(db:db)
                
                DispatchQueue.main.async {
                    self.deactivateSelectionMode()
                    self.view.makeToast("Selected scans deleted", duration: 3.0, position: .top)
                    self.refresh()
                    self.selectedIds.removeAll()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func exportCSV(scans:[[String:Any]]) {
    
        //get path for Documents
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        //get date/time and format it
        let fmtr = DateFormatter()
        fmtr.dateFormat = "'Exported 'YYYY-MM-DD hh:mm:SS a"
        let fileName = fmtr.string(from: Date())
        let filePath = "\(paths[0])/\(fileName).csv"
        
        let stream = OutputStream(toFileAtPath: filePath, append: false)!
        let csv = try! CSVWriter(stream: stream)

        try! csv.write(row: ["Captured", "Type", "Value"])
        
        fmtr.dateFormat = "MM/dd/YYYY hh:mm:ss a"
        for scan in scans {
            let captured = fmtr.string(from: scan["Captured"] as! Date)
            let type = scan["Type"] as! String
            let value = scan["Payload"] as! String
            try! csv.write(row: [captured, type, value])
        }
        
        csv.stream.close()
    }
    
    @IBOutlet weak var exportBarButton: UIBarButtonItem!
    @IBAction func exportSelectedScans(_ sender: Any) {
        let db = cache?.openDb()
        if let scans = cache?.scanSummariesForExport(db: db, withIds: selectedIds) {
            exportCSV(scans: scans)
        }
        cache?.closeDb(db:db)
        
        DispatchQueue.main.async {
            self.deactivateSelectionMode()
            self.selectedIds.removeAll()
            self.refresh()
            self.view.makeToast("Selected scans exported", duration: 3.0, position: .top)
        }
    }
    
    @IBAction func toggleSelection(_ sender: Any) {
        if selectModeIsActive {
            if selectedIds.count > 0 {
            
            }
            //actually, check to see if there are active selections.
            //if there are, display an alert with "Proceed" and "Never mind" buttons
            //else, just
            deactivateSelectionMode()
        }
        else {
            activateSelectionMode()
        }
    }
    
    func showNoScansView() {
        self.noScansView.isHidden = false
        self.view.bringSubview(toFront: noScansView)
    }
    
    func hideNoScansView() {
        self.noScansView.isHidden = true
    }
    
    func activateSelectionMode() {
        self.trashCanBarButton.isEnabled = true
        self.exportBarButton.isEnabled = true
        self.cameraButton.isEnabled = false
        self.selectModeIsActive = true
        self.scansTable.reloadData()
        selectButton.title = "Done"
    }
    
    func deactivateSelectionMode() {
        self.trashCanBarButton.isEnabled = false
        self.exportBarButton.isEnabled = false
        self.cameraButton.isEnabled = true
        self.selectModeIsActive = false
        self.scansTable.reloadData()
        selectButton.title = "Select"
    }
    
    @IBOutlet weak var scansTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] {
            self.versionLabel.text = "MultiScan \(version).\(build)"
        }
        
        self.cache = ScansCache.shared
        self.cache?.prepare()
        self.trashCanBarButton.isEnabled = false
        self.exportBarButton.isEnabled = false
        self.cameraButton.isEnabled = true
        self.helpOverlay.isHidden = true
        let gestureRecog = UITapGestureRecognizer(target: self, action: #selector(helpOverlayTapped(sender:)))
        self.helpOverlay.addGestureRecognizer(gestureRecog)
    }

    @objc func helpOverlayTapped(sender:Any?) {
        self.helpOverlay.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh() {
        let db:OpaquePointer? = cache?.openDb()
        self.scans = []
        if let rows = cache?.scanSummaries(db: db, limit: maxNumberOfScans) {
            self.scans = rows
            self.scansTable.reloadData()
        }
        cache?.closeDb(db: db)
        if self.scans.count < 1 {
            self.showNoScansView()
        }
        else {
            self.hideNoScansView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return scans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scanRow = self.scans[indexPath.row]
        let scanId = scanRow["Id"] as! Int64
        
        if selectModeIsActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScanSelectionCell") as! ScanSelectionCell
            cell.setFrom(scan:scanRow)
            cell.setSelectionStatus(to: selectedIds.contains(scanId))
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanCell") as! ScanCell
        cell.setFrom(scan:scanRow)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scanRow = self.scans[indexPath.row]
        let scanId = scanRow["Id"] as! Int64
        if selectModeIsActive {
            if selectedIds.contains(scanId) {
                selectedIds.remove(scanId)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            else {
                selectedIds.insert(scanId)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        else {
            self.performSegue(withIdentifier: "ShowScanDetail", sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
        if selectModeIsActive {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        
            let scanRow = self.scans[indexPath.row]
            let scanId = scanRow["Id"] as! Int64
            
            let db = cache?.openDb()
            _ = cache?.removeScan(db: db, scanId: scanId)
            cache?.closeDb(db: db)
            
            self.refresh()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if "StartScanning" == identifier && scans.count >= maxNumberOfScans {
            displayLimitWasHitAlert()
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "StartScanning" == segue.identifier {
            let vc = segue.destination as! BarcodeScannerController
            vc.scanDelegate = self
        }
        else
        if "ShowScanDetail" == segue.identifier {
            let vc = segue.destination as! ScanDetailViewController
            let path = sender as! IndexPath
            let row = self.scans[path.row]
            vc.scanId = (row["Id"] as! Int64)
            
        }
    }
    
    func displayLimitWasHitAlert() {
        let alert = UIAlertController(title: "Note", message: "Your limit of \(maxNumberOfScans) scans has been reached.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Drat", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setValueToScannedBarcode(value: String, type: String) -> Bool {
        if scans.count < maxNumberOfScans {
            let captured = Date()
            
            let db = cache?.openDb()
            _ = cache?.addScan(db: db, lat: 0, lon: 0, address: "", capturedImage: nil, captured: captured, type: type, payload: value)
            cache?.closeDb(db: db)
            
            return true
        }
        else {
            displayLimitWasHitAlert()
        }
        return false
    }        
}

