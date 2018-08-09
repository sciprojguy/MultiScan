//
//  ScansCache.swift
//  MultiScan
//
//  Created by Chris Woodard as a test app for ActSoft on 6/19/18.
//  Copyright © 2018 ActSoft. All rights reserved.
//

import Foundation
import sqlite3

class ScansCache {

    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)

    public static var shared:ScansCache? = ScansCache()
    
    let versions:[String] = ["1.0"]
    var dbPath:String = ""
    
    private init() {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        self.dbPath = "\(paths[0])/Scans.db"
    }
    
    func addScan(db:OpaquePointer?, lat:Double?, lon:Double?, address:String?, capturedImage:Data?, captured:Date, type:String, payload:String) -> Int32 {
    
        let sql = "INSERT INTO Scans (Type, Latitude, Longitude, Address, Captured, Payload, CapturedImage) VALUES( ?, ?, ?, ?, ?, ?, ? )"
        var stmt:OpaquePointer? = nil
        var result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        
        if SQLITE_OK != result {
            sqlite3_finalize(stmt)
            return result
        }
        
        result = bindString(stmt: stmt, index: 1, value: type)
        
        if let latitude = lat, let longitude = lon {
            result = bindDouble(stmt: stmt, index: 2, value: latitude)
            result = bindDouble(stmt: stmt, index: 3, value: longitude)
        }
        else {
            result = bindDouble(stmt: stmt, index: 2, value: -9999.0)
            result = bindDouble(stmt: stmt, index: 3, value: -9999.0)
        }
        
        if let capturedAddress = address {
            result = bindString(stmt: stmt, index: 4, value: capturedAddress)
        }
        else {
            result = bindString(stmt: stmt, index: 4, value: "")
        }
        
        result = bindDate(stmt: stmt, index: 5, value: captured)
        result = bindString(stmt: stmt, index: 6, value: payload)

        result = sqlite3_step(stmt)
        if SQLITE_BUSY == result {
            NSLog("busy")
        }
        else
        if SQLITE_LOCKED == result {
            NSLog("locked")
        }
        else
        if SQLITE_DONE != result {
            result = SQLITE_ERROR
        }
        
        sqlite3_finalize(stmt)
        return result
    }
    
    func scanSummariesForExport(db:OpaquePointer?, withIds:Set<Int64>) -> [[String:Any]]? {
        let str = withIds.map { return "\($0)"}.joined(separator: ",")
        var summaries:[[String:Any]]? = nil
        //select id, captured, latitude, longitude, type from scans;
        let sql = "SELECT Id, Type, Captured, Latitude, Longitude, Address, Payload FROM Scans WHERE Id IN (\(str))"
        var stmt:OpaquePointer? = nil
        var result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        
        if SQLITE_OK != result {
            sqlite3_finalize(stmt)
            return nil
        }
        
        summaries = []
        result = sqlite3_step(stmt)
        while SQLITE_ROW == result {
            
            let rowId = sqlite3_column_int64(stmt, 0)
            
            var typeStr = ""
            if let typeText = sqlite3_column_text(stmt, 1) {
                typeStr = String(cString: typeText)
            }
            
            let capturedInterval = sqlite3_column_double(stmt, 2)
            let captured = Date(timeIntervalSince1970: capturedInterval)
            
            let latitude = sqlite3_column_double(stmt, 3)
            let longitude = sqlite3_column_double(stmt, 4)
        
            var addressStr = ""
            if let addressText = sqlite3_column_text(stmt, 5) {
                addressStr = String(cString: addressText)
            }
            
            var payload = ""
            if let payloadText = sqlite3_column_text(stmt, 6) {
                payload = String(cString: payloadText)
            }
            
            let summary:[String:Any] = [
                "Id" : rowId,
                "Type" : typeStr,
                "Captured" : captured,
                "Latitude" : latitude,
                "Longitude" : longitude,
                "Address" : addressStr,
                "Payload" : payload
            ]
            
            summaries?.append(summary)
            
            result = sqlite3_step(stmt)
        }
        
        result = sqlite3_finalize(stmt)
        
        return summaries
    }

    func scanSummaries(db:OpaquePointer?, limit:Int) -> [[String:Any]]? {
        var summaries:[[String:Any]]? = nil
        //select id, captured, latitude, longitude, type from scans;
        let sql = "SELECT Id, Type, Captured, Latitude, Longitude, Address, Payload FROM Scans"
        var stmt:OpaquePointer? = nil
        var result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        var rowCount:Int = 0
        
        if SQLITE_OK != result {
            sqlite3_finalize(stmt)
            return nil
        }
        
        summaries = []
        result = sqlite3_step(stmt)
        while SQLITE_ROW == result {
            
            let rowId = sqlite3_column_int64(stmt, 0)
            
            var typeStr = ""
            if let typeText = sqlite3_column_text(stmt, 1) {
                typeStr = String(cString: typeText)
            }
            
            let capturedInterval = sqlite3_column_double(stmt, 2)
            let captured = Date(timeIntervalSince1970: capturedInterval)
            
            let latitude = sqlite3_column_double(stmt, 3)
            let longitude = sqlite3_column_double(stmt, 4)
        
            var addressStr = ""
            if let addressText = sqlite3_column_text(stmt, 5) {
                addressStr = String(cString: addressText)
            }
            
            var payload = ""
            if let payloadText = sqlite3_column_text(stmt, 6) {
                payload = String(cString: payloadText)
            }
            
            let summary:[String:Any] = [
                "Id" : rowId,
                "Type" : typeStr,
                "Captured" : captured,
                "Latitude" : latitude,
                "Longitude" : longitude,
                "Address" : addressStr,
                "Payload" : payload
            ]
            
            summaries?.append(summary)
            
            if rowCount >= limit {
                break
            }

            rowCount += 1
            result = sqlite3_step(stmt)
        }
        
        result = sqlite3_finalize(stmt)
        
        return summaries
    }
    
    func scanDetail(db:OpaquePointer?, scanId:Int64) -> [String:Any]? {
    
        var detail:[String:Any]? = nil

        let sql = "SELECT Id, Type, Captured, Latitude, Longitude, Address, Payload FROM Scans WHERE Id = \(scanId)"
        var stmt:OpaquePointer? = nil
        var result = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        
        if SQLITE_OK != result {
            return nil
        }

        result = sqlite3_step(stmt)
        if SQLITE_ROW == result {
            
            let rowId = sqlite3_column_int64(stmt, 0)
            
            var typeStr = ""
            if let typeText = sqlite3_column_text(stmt, 1) {
                typeStr = String(cString: typeText)
            }
            
            var payload = ""
            if let payloadText = sqlite3_column_text(stmt, 6) {
                payload = String(cString: payloadText)
            }

            let capturedInterval = sqlite3_column_double(stmt, 2)
            let captured = Date(timeIntervalSince1970: capturedInterval)
            
            let latitude = sqlite3_column_double(stmt, 3)
            let longitude = sqlite3_column_double(stmt, 4)
        
            var address = ""
            if let addressText = sqlite3_column_text(stmt, 5) {
                address = String(cString: addressText)
            }
            
            //todo: bring up Image and pass it back as Data
            
            detail = [
                "Id" : rowId,
                "Type" : typeStr,
                "Captured" : captured,
                "Latitude" : latitude,
                "Longitude" : longitude,
                "Address" : address,
                "Payload" : payload
            ]

        }
        
        sqlite3_finalize(stmt)
        
        return detail
    }
    
    func removeScan(db:OpaquePointer?, scanId:Int64) -> Int32 {
        let sql = "DELETE FROM Scans WHERE Id = \(scanId)"
        return sqlite3_exec(db, sql, nil, nil, nil)
    }
    
    func removeScans(db:OpaquePointer?, withIds:Set<Int64>) -> Int32 {
        let str = withIds.map { return "\($0)"}.joined(separator: ",")
        let sql = "DELETE FROM Scans WHERE Id IN (\(str))"
        return sqlite3_exec(db, sql, nil, nil, nil)
    }
    
    //MARK: - SQLite support
    
    func openDb() -> OpaquePointer? {
        var db:OpaquePointer? = nil
        if SQLITE_OK == sqlite3_open(self.dbPath, &db) {
            return db
        }
        return nil
    }

    func closeDb(db:OpaquePointer?) {
        sqlite3_close(db)
    }
    
    func begin_transaction(db:OpaquePointer?) {
        sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil)
    }
    
    func commit_transaction(db:OpaquePointer?) {
        sqlite3_exec(db, "COMMIT", nil, nil, nil)
    }
    
    func rollback_transaction(db:OpaquePointer?) {
        sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
    }
    
    func createCache(db:OpaquePointer?, version:String) {
        if let sqlStatements = self.sql(name: "Create_Cache_\(version)") {
            var result = SQLITE_OK
            self.begin_transaction(db: db)
            for statement in sqlStatements {
                result = sqlite3_exec(db, statement, nil, nil, nil)
                if SQLITE_OK != result {
                    break
                }
            }
            if SQLITE_OK == result {
                self.commit_transaction(db: db)
            }
            else {
                self.rollback_transaction(db: db)
            }
        }
    }
    
    func migrateCache(db:OpaquePointer?, fromVersion:String, toVersion:String) {
        if let sqlStatements = self.sql(name: "Migrate_Cache_\(fromVersion)_\(toVersion)") {
            var result = SQLITE_OK
            self.begin_transaction(db: db)
            for statement in sqlStatements {
                result = sqlite3_exec(db, statement, nil, nil, nil)
                if SQLITE_OK != result {
                    break
                }
            }
            if SQLITE_OK == result {
                self.commit_transaction(db: db)
            }
            else {
                self.rollback_transaction(db: db)
            }
        }
    }
    
    func sql(name:String) -> [String]? {
        let bundle = Bundle.main
        if let path = bundle.path(forResource: name, ofType: "sql") {
            if let sql = try? String(contentsOfFile: path) {
                return sql.components(separatedBy: ";")
            }
        }
        return nil
    }
    
    func cachedVersion(db:OpaquePointer?) -> String? {
        var version:String? = nil
        var stmt:OpaquePointer? = nil
        var result = sqlite3_prepare_v2(db, "SELECT version FROM Version", -1, &stmt, nil)
        if SQLITE_OK == result {
            result = sqlite3_step(stmt)
            if SQLITE_ROW == result {
                if let rawText = sqlite3_column_text(stmt, 0) {
                    version = String(cString: rawText)
                }
            }
        }
        sqlite3_finalize(stmt)
        return version
    }
    
    func prepare() {
        var db:OpaquePointer? = nil
        let result = sqlite3_open(self.dbPath, &db)
        if SQLITE_OK == result {
            if let currentVersion = self.versions.last {
                if let cachedVersion = self.cachedVersion(db: db!) {
                    //cached version, migrate if necessary
                    if cachedVersion != currentVersion {
                        migrateCache(db:db, fromVersion: cachedVersion, toVersion: currentVersion)
                    }
                }
                else {
                    //no cached version, create
                    createCache(db: db, version: currentVersion)
                }
            }
        }
        sqlite3_close(db)
    }

    func resetSingleton() {
        let fm = FileManager.default
        if ((try? fm.removeItem(atPath: self.dbPath)) != nil) {
            NSLog("db removed")
        }
//        ScansCache.shared = nil
    }
    
    func bindInt(stmt:OpaquePointer?, index:Int32, value:Int32) -> Int32 {
        return sqlite3_bind_int(stmt, index, value)
    }
    
    func bindInt64(stmt:OpaquePointer?, index:Int32, value:Int64) -> Int32 {
        return sqlite3_bind_int64(stmt, index, value)
    }
    
    func bindDouble(stmt:OpaquePointer?, index:Int32, value:Double) -> Int32 {
        return sqlite3_bind_double(stmt, index, value)
    }

    func bindDate(stmt:OpaquePointer?, index:Int32, value:Date) -> Int32 {
        return sqlite3_bind_double(stmt, index, value.timeIntervalSince1970)
    }
    
    func bindString(stmt:OpaquePointer?, index:Int32, value:String) -> Int32 {
        return sqlite3_bind_text(stmt, index, value, Int32(value.lengthOfBytes(using: .utf8)), SQLITE_TRANSIENT)
    }

    func bindBlob(stmt:OpaquePointer?, index:Int32, imgData:Data?) -> Int32 {
    
        if let data = imgData {
        
            let size = MemoryLayout<Int8>.stride
            let int8s = data.withUnsafeBytes { (bytes: UnsafePointer<Int8>) in
                Array(UnsafeBufferPointer(start: bytes, count: data.count / size))
            }

            return sqlite3_bind_blob(stmt, index, int8s, Int32(data.count), SQLITE_TRANSIENT)
        }
        
        return SQLITE_EMPTY
    }
}
