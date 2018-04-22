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
    
    private static var documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // MARK: Manage Files
    
    private static func getAllJsonsURLs() -> [URL]{
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
    
    static func saveToDocuments(json: JSON) {
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
    
    static func readFromDocuments(fileUrl: URL) -> Data? {
        let filePath = getFilePath(fileURL: fileUrl)
        
        if FileManager.default.fileExists(atPath: filePath), let data = FileManager.default.contents(atPath: filePath) {
            return data
        }
        return nil
    }
    
    static func deleteAllJsonFilesFromDisk() {
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
    
    static func printAllJsons() {
        let jsonURLs = getAllJsonsURLs()
        
        print("JsonFileManager printAllJsons():")
        for url in jsonURLs {
            let (fileName: fileName, fileExtension: fileExtension) = getFileComponents(fileURL: url)
            
            print("\(fileName).\(fileExtension)")
        }
    }
    
    // MARK: Utilities
    
    private static func getFileName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh-mm-ss a"
        return formatter.string(from: date)
    }
    
    private static func getFileComponents(fileURL: URL) -> (fileName: String, fileExtension: String) {
        let fileURLParts = fileURL.path.components(separatedBy: "/")
        let fileName = fileURLParts.last
        let filenameParts = fileName?.components(separatedBy: ".")
        
        return (filenameParts![0], filenameParts![1])
    }
    
    private static func getFilePath(fileURL: URL) -> String {
        let (fileName: fileName, fileExtension: fileExtension) =  getFileComponents(fileURL: fileURL)
        
        return documentsURL.appendingPathComponent("\(fileName).\(fileExtension)").path
    }

}
