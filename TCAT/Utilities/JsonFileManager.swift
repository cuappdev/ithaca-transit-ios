//
//  JsonFileManager.swift
//  TCAT
//
//  Created by Monica Ong on 4/22/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import SwiftyJSON

class JsonFileManager {
    
    // MARK: Singleton vars
    
    static let shared = JsonFileManager()
    
    // MARK: File vars
    
    private var documentsURL: URL
    private var logURL: URL
    
    // MARK: Initialization
    
    private init() {
        do {
            documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            logURL = documentsURL.appendingPathComponent("log.txt")
            
            let line = "\(getTimeStampString(from: Date())): Initialized JsonFileManager\n"
            try line.write(to: logURL, atomically: false, encoding: .utf8)
        }
        catch {
            let line = "JsonFileManager init(): \(error)"
            print(line)
            
            try? "\(getTimeStampString(from: Date())): \(line)\n".write(to: logURL, atomically: false, encoding: .utf8)
        }
    }
    
    // MARK: Manage Files
    
    private func getAllJsonsURLs() -> [URL]{
        var jsonURLs: [URL] = []

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for url in fileURLs {
                let (fileName: _, fileExtension: fileExtension) = getFileComponents(fileURL: url)
                
                if fileExtension == "json" {
                    jsonURLs.append(url)
                }
            }
            
            return jsonURLs
        }
        catch {
            printAndLog(timestamp: Date(), line: "JsonFileManager getAllJsonsURLs(): Error while enumerating files at \(documentsURL.path): \(error.localizedDescription)")
        }
        
        return jsonURLs
    }
    
    private func getFileComponents(fileURL: URL) -> (fileName: String, fileExtension: String) {
        let fileURLParts = fileURL.path.components(separatedBy: "/")
        let fileName = fileURLParts.last
        let filenameParts = fileName?.components(separatedBy: ".")
        
        return (filenameParts![0], filenameParts![1])
    }
    
    private func getFilePath(fileURL: URL) -> String {
        let (fileName: fileName, fileExtension: fileExtension) =  getFileComponents(fileURL: fileURL)
        
        return documentsURL.appendingPathComponent("\(fileName).\(fileExtension)").path
    }
    
    // MARK: Read/write Jsons
    
    func saveToDocuments(json: JSON) {
        do {
            let jsonData = try json.rawData()
            
            let fileName = getFileNameString(from: Date())
            let fileExtension = "json"
            let fileURL = documentsURL.appendingPathComponent("\(fileName).\(fileExtension)")
            
            try jsonData.write(to: fileURL, options: .atomic)
            
            printAndLog(timestamp: Date(), line: "Wrote \(fileName).\(fileExtension) to documents directory")
        }
        catch {
            printAndLog(timestamp: Date(), line: "JsonFileManager saveToDisk(): \(error)")
        }
    }
    
    func readFromDocuments(fileUrl: URL) -> Data? {
        let filePath = getFilePath(fileURL: fileUrl)
        
        if FileManager.default.fileExists(atPath: filePath), let data = FileManager.default.contents(atPath: filePath) {
            return data
        }
        return nil
    }
    
    func deleteAllJsonFilesFromDisk() {
        let jsonURLs = getAllJsonsURLs()
        
        for url in jsonURLs {
            let filePath = getFilePath(fileURL: url)
            
            do {
                try FileManager.default.removeItem(atPath: filePath)
                
                let (fileName: fileName, fileExtension: fileExtension) = getFileComponents(fileURL: url)
                printAndLog(timestamp: Date(), line: "Deleted \(fileName).\(fileExtension)")
            }
            catch let error as NSError {
                let (fileName: fileName, fileExtension: fileExtension) =  getFileComponents(fileURL: url)
                printAndLog(timestamp: Date(), line: "FileManager deleteAllJsonFiles(): Error for \(fileName).\(fileExtension) \(error.debugDescription)")
            }
        }
    }
    
    // MARK: Read/write log
    
    func writeToLog(timestamp: Date, line: String) {
        if let data = "\(getTimeStampString(from: timestamp)): \(line)\n".data(using: .utf8), let fileHandle = FileHandle(forWritingAtPath: logURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            
            print("JsonFileManager writeToLog(): successful")
        }
        else {
            print("JsonFileManager writeToLog(): failed")
        }
    }
    
    func readFromLog() -> String? {
        if let log = try? String(contentsOf: logURL, encoding: .utf8) {
            print("JsonFileManager readFromLog(): successful")
            return log
        }
        
        print("JsonFileManager readFromLog(): failed")
        return nil
    }
    
    // MARK: Print
    
    private func printAndLog(timestamp: Date, line: String) {
        print(line)
        writeToLog(timestamp: timestamp, line: line)
    }
    
    private func printData(_ data: Data) {
        let string = String(data: data, encoding: .utf8)
        print("JsonFileManager printData(): \(string!)")
    }
    
    func printAllJsons() {
        let jsonURLs = getAllJsonsURLs()
        
        print("JsonFileManager printAllJsons():")
        for url in jsonURLs {
            let (fileName: fileName, fileExtension: fileExtension) = getFileComponents(fileURL: url)
            
            print("    \(fileName).\(fileExtension)")
        }
    }
    
    // MARK: Date Formatting
    
    private func getFileNameString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd a hh-mm-ss"
        return formatter.string(from: date)
    }
    
    private func getTimeStampString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/y E h:mm:ss a (zzz)"
        return formatter.string(from: date)
    }

}
