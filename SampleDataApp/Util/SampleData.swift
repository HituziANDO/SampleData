//
// SampleData
//
// MIT License
//
// Copyright (c) 2019-present Hituzi Ando
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

open class SampleData {

    /// A path of the "sampledata" directory.
    public static let dataDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/sampledata"

    private static let className = String(describing: SampleData.self)

    /// Returns the default instance. If the "sampledata" directory does not exist, it is created in the Documents directory.
    public static var `default`: SampleData = {
        do {
            if !FileManager.default.fileExists(atPath: dataDirectory) {
                try FileManager.default.createDirectory(atPath: dataDirectory, withIntermediateDirectories: true)
            }
        }
        catch {
            print("[\(className)] \(error)")
        }

        return SampleData()
    }()

    /// Imports sample data as a JSON object when specified file is not locked.
    ///
    /// - Parameters:
    ///   - fileName: A file name of sample data.
    ///   - lock: If true, locks the file import or export operation after importing.
    /// - Returns: Sample data.
    public func `import`(dataOfFile fileName: String, lock: Bool = false) -> Any? {
        let filePath     = "\(Self.dataDirectory)/\(fileName)"
        let lockFilePath = "\(filePath).lock"

        if lock && isLocked(lockFilePath) {
            return nil
        }

        if FileManager.default.fileExists(atPath: filePath) {
            do {
                let json = try String(contentsOfFile: filePath)
                let obj  = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: .allowFragments)

                if lock {
                    try lockFile(lockFilePath)
                }

                return obj
            }
            catch {
                print("[\(Self.className)] \(error)")
            }
        }
        else {
            print("[\(Self.className)] \(filePath) not found.")
        }

        return nil
    }

    /// Imports sample data as a object of specified type when specified file is not locked.
    ///
    /// - Parameters:
    ///   - fileName: A file name of sample data.
    ///   - cls: A model's class.
    ///   - lock: If true, locks the file import or export operation after importing.
    /// - Returns: Sample data.
    public func `import`<T: Decodable>(dataOfFile fileName: String, ofType cls: T.Type, lock: Bool = false) -> T? {
        let filePath     = "\(Self.dataDirectory)/\(fileName)"
        let lockFilePath = "\(filePath).lock"
        return `import`(cls, atFilePath: filePath, lockFilePath: lockFilePath, lock: lock)
    }

    /// Imports sample data in the main bundle as a object of specified type when specified file is not locked.
    /// 
    /// - Parameters:
    ///   - fileName: A file name of sample data in the main bundle.
    ///   - cls: A model's class.
    ///   - lock: If true, locks the file import or export operation after importing.
    /// - Returns: Sample data.
    public func `import`<T: Decodable>(dataOfMainBundleResource fileName: String, ofType cls: T.Type, lock: Bool = false) -> T? {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: nil) else { return nil }
        let lockFilePath = "\(Self.dataDirectory)/\(fileName).lock"
        return `import`(cls, atFilePath: filePath, lockFilePath: lockFilePath, lock: lock)
    }

    /// Exports data as a sample when specified file is not locked.
    ///
    /// - Parameters:
    ///   - data: A data.
    ///   - fileName: A file name of sample data.
    ///   - lock: If true, locks the file import or export operation after exporting.
    /// - Returns: true if exported the data, otherwise false.
    public func export<T: Encodable>(data: T, to fileName: String, lock: Bool = false) -> Bool {
        let filePath     = "\(Self.dataDirectory)/\(fileName)"
        let lockFilePath = "\(filePath).lock"
        var success      = false

        if lock && isLocked(lockFilePath) {
            return success
        }

        do {
            let encodedData = try JSONEncoder().encode(data)
            try encodedData.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            defer { success = true }

            if lock {
                try lockFile(lockFilePath)
            }
        }
        catch {
            print("[\(Self.className)] \(error)")
        }

        return success
    }

    /// Unlocks specified file import or export operation.
    ///
    /// - Parameters:
    ///   - fileName: A file name of sample data.
    public func unlock(_ fileName: String) {
        let lockFilePath = "\(Self.dataDirectory)/\(fileName)" + (fileName.hasSuffix(".lock") ? "" : ".lock")

        do {
            if FileManager.default.fileExists(atPath: lockFilePath) {
                try FileManager.default.removeItem(atPath: lockFilePath)
            }
        }
        catch {
            print("[\(Self.className)] \(error)")
        }
    }

    /// Deletes all files in the "sampledata" directory.
    public func clean() {
        let path = Self.dataDirectory

        do {
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
            }

            if !FileManager.default.fileExists(atPath: path) {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            }
        }
        catch {
            print("[\(Self.className)] \(error)")
        }
    }

    // MARK: private

    private func `import`<T: Decodable>(_ cls: T.Type?, atFilePath filePath: String, lockFilePath: String, lock: Bool) -> T? {
        if lock && isLocked(lockFilePath) {
            return nil
        }

        if FileManager.default.fileExists(atPath: filePath) {
            do {
                let json = try String(contentsOfFile: filePath)
                let obj  = try JSONDecoder().decode(cls!, from: json.data(using: .utf8)!)

                if lock {
                    try lockFile(lockFilePath)
                }

                return obj
            }
            catch {
                print("[\(Self.className)] \(error)")
            }
        }
        else {
            print("[\(Self.className)] \(filePath) not found.")
        }

        return nil
    }

    private func isLocked(_ lockFilePath: String) -> Bool {
        if FileManager.default.fileExists(atPath: lockFilePath) {
            if let lock = try? String(contentsOf: URL(fileURLWithPath: lockFilePath), encoding: .utf8), lock == "true" {
                return true
            }
        }
        return false
    }

    private func lockFile(_ lockFilePath: String) throws {
        try "true".write(to: URL(fileURLWithPath: lockFilePath), atomically: true, encoding: .utf8)
    }
}
