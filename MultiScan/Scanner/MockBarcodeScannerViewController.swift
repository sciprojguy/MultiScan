//
//  MockBarcodeScannerViewController.swift
//  MultiScan
//
//  Created by Chris Woodard on 6/21/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import UIKit

class MockBarcodeScannerViewController: UITableViewController {

    var scanDelegate:ScanValueDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if 0 == indexPath.row {
            _ = self.scanDelegate?.setValueToScannedBarcode(value: "http://www.petsounds.com", type: "QR")
        }
        else
        if 1 == indexPath.row {
            _ = self.scanDelegate?.setValueToScannedBarcode(value: "Joe The Electrician", type: "QR")
        }
        if 2 == indexPath.row {
            _ = self.scanDelegate?.setValueToScannedBarcode(value: "1234567789", type: "EAN-13")
        }
        if 3 == indexPath.row {
            _ = self.scanDelegate?.setValueToScannedBarcode(value: "909810394809", type: "EAN-13")
        }
        if 4 == indexPath.row {
            _ = self.scanDelegate?.setValueToScannedBarcode(value: "9090192019", type: "EAN-9")
        }
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
