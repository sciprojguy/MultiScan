//
//  CodeRecognitionTableViewController.swift
//  MultiScan
//
//  Created by Chris Woodard on 7/11/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import UIKit
import AVFoundation

class CodeRecognitionTableViewController: UITableViewController {

    var types:[String] = []
    var selectedTypes = Set<String>()
    
    @IBAction func applyTypes(_ sender: Any) {
    }
    
    func rearFacingCamera() -> AVCaptureDevice? {
    
        var rearCamera : AVCaptureDevice?

        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                rearCamera = device
            }
        }
        
        return rearCamera
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       guard let captureDevice = self.rearFacingCamera()
        else {
            return
        }

        var captureSession = AVCaptureSession()
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        if let input = try? AVCaptureDeviceInput(device: captureDevice) {
        
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            for type in captureMetadataOutput.availableMetadataObjectTypes {
                let nodes = type.rawValue.split(separator: ".")
                types.append(String(nodes.last!))
            }
        }
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
        return types.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
        let type = types[indexPath.row]
        if selectedTypes.contains(type) {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = type
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = types[indexPath.row]
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        }
        else {
            selectedTypes.insert(type)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
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
