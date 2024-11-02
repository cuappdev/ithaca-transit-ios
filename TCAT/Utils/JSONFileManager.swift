//
//  JsonFileManager.swift
//  TCAT
//
//  Created by Monica Ong on 4/22/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import SwiftyJSON
import UIKit
import Zip

enum JSONType {
    case routeJSON
    case delayJSON(routeId: String)

    func rawValue() -> String {
        switch self {
        case .routeJSON:
            return "routeJSON"

        case .delayJSON:
            return "delayJSON"
        }
    }
}

class JSONFileManager {

    // MARK: - Singleton vars

    static let shared = JSONFileManager()

    // MARK: - File vars

    private let documentsURL: URL
    private let logURL: URL
    private let zipURL: URL
    private let logFileName = "log.txt"
    private let zipFileName = "log.zip"

    // MARK: - Print vars

    private let fileName = "JSONFileManager"

    // MARK: - Initialization

    private init() {
        documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        logURL = documentsURL.appendingPathComponent(logFileName)
        zipURL = documentsURL.appendingPathComponent(zipFileName)

        do {
            let line = "\(getTimeStampString(from: Date())): \(fileName) \(#function): Initialized JSONFileManager\n"
            try line.write(to: logURL, atomically: false, encoding: .utf8)
        } catch {
            let line = "\(fileName) \(#function): \(error)"
            print(line)

            let logLine = "\(getTimeStampString(from: Date())): \(line)\n"
            try? logLine.write(to: logURL, atomically: false, encoding: .utf8)
        }
    }

    // MARK: - Manage Zipping

    /// Get the zipped file containing all JSON logs on device
    func getZipURL() -> URL? {
        let fileUrls = getAllFileURLs()

        do {
            try Zip.zipFiles(paths: fileUrls, zipFilePath: zipURL, password: nil, progress: nil)
            printAndLog(timestamp: Date(), line: "\(fileName) \(#function): Zipped all files to \(zipURL)")
            return zipURL
        } catch {
            printAndLog(timestamp: Date(), line: "\(fileName) \(#function): \(error)")
            return nil
        }
    }

    func deleteZip() {
        if FileManager.default.fileExists(atPath: zipURL.path) {
            do {
                try FileManager.default.removeItem(atPath: zipURL.path)

                printAndLog(timestamp: Date(), line: "\(fileName) \(#function): Deleted \(zipFileName)")
            } catch let error as NSError {
                printAndLog(
                    timestamp: Date(),
                    line: "\(fileName) \(#function): Error when deleting \(zipFileName) \(error.debugDescription)"
                )
            }
        }
    }

    // MARK: - Manage Files

    private func getAllFileURLs() -> [URL] {
        return [logURL] + getAllJSONURLs()
    }

    private func readFromDocuments(fileUrl: URL) -> Data? {
        let filePath = getFilePath(fileURL: fileUrl)

        if FileManager.default.fileExists(atPath: filePath), let data = FileManager.default.contents(atPath: filePath) {
            return data
        }
        return nil
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

    // MARK: - Manage Jsons

    func saveJSON(_ json: JSON, type: JSONType) {
        do {
            let jsonData = try json.rawData()

            let jsonFileName = getFileNameString(date: Date(), type: type)
            let jsonFileExtension = "json"
            let jsonFileURL = documentsURL.appendingPathComponent("\(jsonFileName).\(jsonFileExtension)")

            try jsonData.write(to: jsonFileURL, options: .atomic)

            printAndLog(
                timestamp: Date(),
                // swiftlint:disable:next line_length
                line: "\(fileName) \(#function): Wrote \(type) to documents directory. Name: \(jsonFileName).\(jsonFileExtension)"
            )
        } catch {
            printAndLog(timestamp: Date(), line: "\(fileName) \(#function): \(error)")
        }
    }

    func deleteAllJSONs() {
        let jsonURLs = getAllJSONURLs()

        for url in jsonURLs {
            let jsonFilePath = getFilePath(fileURL: url)

            do {
                try FileManager.default.removeItem(atPath: jsonFilePath)

                let (fileName: jsonFileName, fileExtension: jsonFileExtension) = getFileComponents(fileURL: url)
                printAndLog(
                    timestamp: Date(),
                    line: "\(fileName) \(#function): Deleted \(jsonFileName).\(jsonFileExtension)"
                )
            } catch let error as NSError {
                let (fileName: jsonFileName, fileExtension: jsonFileExtension) =  getFileComponents(fileURL: url)
                printAndLog(
                    timestamp: Date(),
                    // swiftlint:disable:next line_length
                    line: "\(fileName) \(#function): Error for \(jsonFileName).\(jsonFileExtension) \(error.debugDescription)"
                )
            }
        }
    }

    private func getAllJSONURLs() -> [URL] {
        var jsonURLs: [URL] = []

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: nil
            )

            for url in fileURLs {
                let (fileName: _, fileExtension: fileExtension) = getFileComponents(fileURL: url)

                if fileExtension == "json" {
                    jsonURLs.append(url)
                }
            }

            return jsonURLs
        } catch {
            printAndLog(
                timestamp: Date(),
                // swiftlint:disable:next line_length
                line: "\(fileName) \(#function):: Error while enumerating files at \(documentsURL.path): \(error.localizedDescription)"
            )
        }

        return jsonURLs
    }

    // MARK: - Manage log

    func logSearchParameters(
        timestamp: Date,
        startPlace: Place,
        endPlace: Place,
        searchTime: Date,
        searchTimeType: SearchType
    ) {
        logLine(
            timestamp: timestamp,
            // swiftlint:disable:next line_length
            line: "Search parameters: startPlace: \(startPlace). endPlace: \(endPlace). searchTime: \(Time.dateString(from: searchTime)). searchTimeType: \(searchTimeType)"
        )
    }

    func logDelayParameters(timestamp: Date, stopId: String, tripId: String) {
        logLine(timestamp: timestamp, line: "Delay parameters: stopId: \(stopId). tripId: \(tripId).")
    }

    func logURL(timestamp: Date, urlName: String, url: String) {
        logLine(timestamp: timestamp, line: "\(urlName): \(url)")
    }

    func readLog() -> String? {
        if let log = try? String(contentsOf: logURL, encoding: .utf8) {
            return log
        }

        print("\(fileName) \(#function): failed")
        return nil
    }

    private func logLine(timestamp: Date, line: String) {
        if let data = "\(getTimeStampString(from: timestamp)): \(line)\n".data(using: .utf8),
           let fileHandle = FileHandle(forWritingAtPath: logURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        } else {
            print("\(fileName) \(#function): failed")
        }
    }

    // MARK: - Print

    func printAllJSONs() {
        let jsonURLs = getAllJSONURLs()

        print("\(fileName) \(#function):")
        for url in jsonURLs {
            let (fileName: fileName, fileExtension: fileExtension) = getFileComponents(fileURL: url)

            print("    \(fileName).\(fileExtension)")
        }
    }

    private func printAndLog(timestamp: Date, line: String) {
        print(line)
        logLine(timestamp: timestamp, line: line)
    }

    private func printData(_ data: Data) {
        let string = String(data: data, encoding: .utf8)
        print("\(fileName) \(#function): \(string!)")
    }

    // MARK: - Date Formatting

    private func getFileNameString(date: Date, type: JSONType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd a hh-mm-ss"
        let dateString = formatter.string(from: date)
        let jsonString = type.rawValue()

        switch type {
        case .routeJSON:
            return "\(dateString) \(jsonString)"
        case .delayJSON(routeId: let routeId):
            return "\(dateString) \(jsonString) \(routeId)"
        }
    }

    private func getTimeStampString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/y E h:mm:ss a (zzz)"
        return formatter.string(from: date)
    }

}
