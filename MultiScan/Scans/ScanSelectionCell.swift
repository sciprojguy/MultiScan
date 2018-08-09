//
//  ScanSelectionCell.swift
//  MultiScan
//
//  Created by Chris Woodard on 6/21/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import UIKit

class ScanSelectionCell: UITableViewCell {

    @IBOutlet var scanTypeLabel:UILabel? = nil
    @IBOutlet var scanContentsLabel:UILabel? = nil
    @IBOutlet var timeAndLocationLabel:UILabel? = nil
    @IBOutlet var selectionImage:UIImageView? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setFrom(scan:[String:Any]) {
    
        let fmtr = DateFormatter()
        fmtr.dateFormat = "'Scanned' EEE, MMM d, YYYY 'at' hh:mm a"
        self.timeAndLocationLabel?.text = fmtr.string(from: scan["Captured"] as! Date)
        
        if let typeValue = scan["Type"] as? String {
            scanTypeLabel?.text = typeValue
        }
        
        if let payloadValue = scan["Payload"] as? String {
            scanContentsLabel?.text = payloadValue
        }
    }

    func setSelectionStatus(to isSelected:Bool) {
        if isSelected {
            self.selectionImage?.image = UIImage(named: "filled_circle.png")
        }
        else {
            self.selectionImage?.image = UIImage(named: "empty_circle.png")
        }
    }
}
