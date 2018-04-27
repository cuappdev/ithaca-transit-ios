//
//  JsonFileManager.swift
//  TCAT
//
//  Created by Monica Ong on 4/22/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import SwiftyJSON

// N2Self: Make sure to fail gracefully. N2 handle errors better, this is superrr messy
// N2 handle edge case where they don't have enough space?

class JsonFileManager {
    
    // MARK: Singleton vars
    
    static let shared = JsonFileManager()
    
    // MARK: File vars
    
    private var documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var logURL: URL
    
    // MARK: Initialization
    
    private init() {
        do {
            // create the destination url for the text file to be saved
            logURL = documentsURL.appendingPathComponent("log.txt")
            let line = "\(getTimeStamp(from: Date())): Initialized JsonFileManager"
            try line.write(to: logURL, atomically: false, encoding: .utf8)
        } catch {
            print("JsonFileManager init: \(error)")
        }
    }
    
    // MARK: Manage Files
    
    private func getAllJsonsURLs() -> [URL]{
        var jsonURLs: [URL] = []

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for url in fileURLs {
                let (fileName: fileName, fileExtension: fileExtension) = getFileComponents(fileURL: url)
                
                if fileExtension == "json" {
                    jsonURLs.append(url)
                }
            }
            
            return jsonURLs
        }
        catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        return jsonURLs
    }
    
    // MARK: Manage Disk
    
    func saveToDocuments(json: JSON) {
        do {
            let jsonData = try json.rawData()
            
            let fileName = getFileName(from: Date())
            let fileURL = documentsURL.appendingPathComponent("\(fileName).json")
            
            try jsonData.write(to: fileURL, options: .atomic)
        }
        catch {
            print("JsonFileManager saveToDisk(): \(error)")
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
            } catch let error as NSError {
                let (fileName: fileName, fileExtension: fileExtension) =  getFileComponents(fileURL: url)
                
                print("FileManager deleteAllJsonFiles(): Error for \(fileName).\(fileExtension) \(error.debugDescription)")
            }
        }
    }
    
    // MARK: Print
    
    private static func printData(_ data: Data) {
        let string = String(data: data, encoding: .utf8)
        print("JsonFileManager printData(): \(string!)")
    }
    
    func printAllJsons() {
        let jsonURLs = getAllJsonsURLs()
        
        print("JsonFileManager printAllJsons():")
        for url in jsonURLs {
            let (fileName: fileName, fileExtension: fileExtension) = getFileComponents(fileURL: url)
            
            print("\(fileName).\(fileExtension)")
        }
    }
    
    // MARK: Utilities
    
    private func getFileName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh-mm-ss a"
        return formatter.string(from: date)
    }
    
    private func getTimeStamp(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/y E h:mm:ss a (zzz)"
        return formatter.string(from: date)
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

}
