//
//  MultiScanTests.swift
//  MultiScanTests
//
//  Created by Chris Woodard on 6/19/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import XCTest
@testable import MultiScan

class MultiScan_CacheTests: XCTestCase {

    var cache:ScansCache? = nil
    
    override func setUp() {
        super.setUp()
        cache = ScansCache.shared
        XCTAssertNotNil(cache)
        cache?.prepare()
    }
    
    override func tearDown() {
        cache?.resetSingleton()
        super.tearDown()
    }
    
    func testScansCache_AddThreeScansAndRetrieveList() {
    
        let db = cache?.openDb()
        
        var result = cache?.addScan(db: db, lat: 10.0, lon: 10.0, address: "1313 Mockingbird Lane, Detroit, MI", capturedImage:nil, captured: Date(), type: "EAN-13", payload: "1234567")
        result = cache?.addScan(db: db, lat: 20.0, lon: 20.0, address: "YET NOE MORE", capturedImage: nil, captured: Date(), type: "EAN-9", payload: "1234567AAA")
        result = cache?.addScan(db: db, lat: 30.0, lon: 30.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "QR", payload: "http://www.google.com")
        
        if let scans = cache?.scanSummaries(db: db, limit: 10) {
            XCTAssertEqual(3, scans.count, "Should be 3 scans, not \(scans.count)")
        }
        else {
            XCTFail("got nil scans array")
        }
        
        cache?.closeDb(db: db)
    }
    
    func testScansCache_AddThreeScans_DeleteFirstOne_AndRetrieveList() {
    
        let db = cache?.openDb()
        
        var result = cache?.addScan(db: db, lat: 10.0, lon: 10.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-13", payload: "1234567")
        result = cache?.addScan(db: db, lat: 20.0, lon: 20.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-9", payload: "1234567AAA")
        result = cache?.addScan(db: db, lat: 30.0, lon: 30.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "QR", payload: "http://www.google.com")
        
        guard let scans = cache?.scanSummaries(db: db, limit: 10)
        else {
            XCTFail("got nil scans array")
            return
        }

        XCTAssertEqual(3, scans.count, "Should be 3 scans, not \(scans.count)")
        
        //delete first one & re-retrieve list
        let firstScan = scans[0] as [String:Any]
        if let firstId = firstScan["Id"] as? Int64 {
            cache?.removeScan(db: db, scanId: firstId)
        }
        else {
            XCTFail("got nil row id")
        }
        
        guard let scans2 = cache?.scanSummaries(db: db, limit: 10)
        else {
            XCTFail("got nil scans array")
            return
        }

        XCTAssertEqual(2, scans2.count, "Should be 2 scans, not \(scans.count)")

        cache?.closeDb(db: db)
    }
    
    func testScansCache_AddThreeScans_DeleteSecondOne_AndRetrieveList() {
    
        let db = cache?.openDb()
        
        var result = cache?.addScan(db: db, lat: 10.0, lon: 10.0, address: "YE OLDE PUB", capturedImage: nil,  captured: Date(), type: "EAN-13", payload: "1234567")
        result = cache?.addScan(db: db, lat: 20.0, lon: 20.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-9", payload: "1234567AAA")
        result = cache?.addScan(db: db, lat: 30.0, lon: 30.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "QR", payload: "http://www.google.com")
        
        guard let scans = cache?.scanSummaries(db: db, limit: 10)
        else {
            XCTFail("got nil scans array")
            return
        }

        XCTAssertEqual(3, scans.count, "Should be 3 scans, not \(scans.count)")
        
        //delete first one & re-retrieve list
        let secondScan = scans[1] as [String:Any]
        if let secondId = secondScan["Id"] as? Int64 {
            cache?.removeScan(db: db, scanId: secondId)
        }
        else {
            XCTFail("got nil row id")
        }
        
        guard let scans2 = cache?.scanSummaries(db: db, limit: 10)
        else {
            XCTFail("got nil scans array")
            return
        }

        XCTAssertEqual(2, scans2.count, "Should be 2 scans, not \(scans.count)")

        cache?.closeDb(db: db)
    }
    
    func testScansCache_AddThreeScans_DeleteThirdOne_AndRetrieveList() {
    
        let db = cache?.openDb()
        
        var result = cache?.addScan(db: db, lat: 10.0, lon: 10.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-13", payload: "1234567")
        result = cache?.addScan(db: db, lat: 20.0, lon: 20.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-9", payload: "1234567AAA")
        result = cache?.addScan(db: db, lat: 30.0, lon: 30.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "QR", payload: "http://www.google.com")
        
        guard let scans = cache?.scanSummaries(db: db, limit: 10)
        else {
            XCTFail("got nil scans array")
            return
        }

        XCTAssertEqual(3, scans.count, "Should be 3 scans, not \(scans.count)")
        
        //delete first one & re-retrieve list
        let thirdScan = scans[2] as [String:Any]
        if let scanId = thirdScan["Id"] as? Int64 {
            cache?.removeScan(db: db, scanId: scanId)
        }
        else {
            XCTFail("got nil row id")
        }
        
        guard let scans2 = cache?.scanSummaries(db: db, limit: 10)
        else {
            XCTFail("got nil scans array")
            return
        }

        XCTAssertEqual(2, scans2.count, "Should be 2 scans, not \(scans.count)")

        cache?.closeDb(db: db)
    }
    
    func testScansCache_AddThreeScansRetrieveList_CheckDetailsForFirst() {
    
        let db = cache?.openDb()
        
        var result = cache?.addScan(db: db, lat: 10.0, lon: 10.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-13", payload: "1234567")
        result = cache?.addScan(db: db, lat: 20.0, lon: 20.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-9", payload: "1234567AAA")
        result = cache?.addScan(db: db, lat: 30.0, lon: 30.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "QR", payload: "http://www.google.com")
        
        guard let scans = cache?.scanSummaries(db: db, limit: 10)
        else {
            XCTFail("got nil scans array")
            return
        }

        XCTAssertEqual(3, scans.count, "Should be 3 scans, not \(scans.count)")
        
        guard let scan = scans[0] as? [String:Any]
        else {
            XCTFail("got nil scan row")
            return
        }
        
        if let scanId = scan["Id"] as? Int64 {
            if let details = cache?.scanDetail(db: db, scanId: scanId) {
                //now compare Id, Captured, Type, Latitude and Longitude
                //verify that Payload is not nil
            }
            else {
                XCTFail("got nil scan detail")
            }
        }
        else {
            XCTFail("got nil scan id")
        }
        cache?.closeDb(db: db)
    }
    
    func testScansCache_AddThreeScansRetrieveList_CheckDetailsForSecond() {
    
        let db = cache?.openDb()
        
        var result = cache?.addScan(db: db, lat: 10.0, lon: 10.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-13", payload: "1234567")
        result = cache?.addScan(db: db, lat: 20.0, lon: 20.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-9", payload: "1234567AAA")
        result = cache?.addScan(db: db, lat: 30.0, lon: 30.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "QR", payload: "http://www.google.com")
        
        guard let scans = cache?.scanSummaries(db: db, limit: 10)
        else {
            XCTFail("got nil scans array")
            return
        }

        XCTAssertEqual(3, scans.count, "Should be 3 scans, not \(scans.count)")
        
        
        guard let scan = scans[1] as? [String:Any]
        else {
            XCTFail("got nil scan row")
            return
        }
        
        if let scanId = scan["Id"] as? Int64 {
            if let details = cache?.scanDetail(db: db, scanId: scanId) {
                //now compare Id, Captured, Type, Latitude and Longitude
                //verify that Payload is not nil
            }
            else {
                XCTFail("got nil scan detail")
            }
        }
        else {
            XCTFail("got nil scan id")
        }

        cache?.closeDb(db: db)
    }
    
    func testScansCache_AddThreeScansRetrieveList_CheckDetailsForThird() {
    
        let db = cache?.openDb()
        
        var result = cache?.addScan(db: db, lat: 10.0, lon: 10.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-13", payload: "1234567")
        result = cache?.addScan(db: db, lat: 20.0, lon: 20.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "EAN-9", payload: "1234567AAA")
        result = cache?.addScan(db: db, lat: 30.0, lon: 30.0, address: "YE OLDE PUB", capturedImage: nil, captured: Date(), type: "QR", payload: "http://www.google.com")
        
        guard let scans = cache?.scanSummaries(db: db, limit: 10)
        else {
            XCTFail("got nil scans array")
            return
        }

        XCTAssertEqual(3, scans.count, "Should be 3 scans, not \(scans.count)")
        
        
        guard let scan = scans[2] as? [String:Any]
        else {
            XCTFail("got nil scan row")
            return
        }
        
        if let scanId = scan["Id"] as? Int64 {
            if let details = cache?.scanDetail(db: db, scanId: scanId) {
                //now compare Id, Captured, Type, Latitude and Longitude
                //verify that Payload is not nil
            }
            else {
                XCTFail("got nil scan detail")
            }
        }
        else {
            XCTFail("got nil scan id")
        }

        cache?.closeDb(db: db)
    }
}
