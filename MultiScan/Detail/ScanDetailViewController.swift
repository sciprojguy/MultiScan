//
//  ScanDetailViewController.swift
//  MultiScan
//
//  Created by Chris Woodard on 6/20/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import UIKit

class ScanDetailViewController: UIViewController {

    var scanId:Int64? = nil
    
    @IBOutlet weak var capturedOnLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var recognizedDataView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cache = ScansCache.shared
        let db = cache?.openDb()
        let scan = cache?.scanDetail(db: db, scanId: scanId!)
        cache?.closeDb(db: db)
        constructUI(scan: scan)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func constructUI(scan:[String:Any]?) {
        if let fullScan = scan {
            let fmtr = DateFormatter()
            fmtr.dateFormat = "'Scanned' EEE, MMM d, YYYY 'at' hh:mm a"
            self.typeLabel.text = "Type: " + (fullScan["Type"] as? String ?? "No data")
            self.capturedOnLabel.text = fmtr.string(from: fullScan["Captured"] as! Date)
            self.recognizedDataView.text = fullScan["Payload"] as! String
        }
        else {
            self.typeLabel.text = "No data"
            self.capturedOnLabel.text = "No data"
            self.recognizedDataView.text = "No data"
        }
    }
    
    override func selectAll(_ sender: Any?) {
        self.recognizedDataView.selectAll(self)
    }

}
