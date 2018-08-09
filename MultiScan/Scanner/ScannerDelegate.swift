//
//  ScannerDelegate.swift
//  MultiScan
//
//  Created by Chris Woodard on 6/21/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import Foundation

protocol ScanValueDelegate {
    func setValueToScannedBarcode(value:String, type:String) -> Bool
}
