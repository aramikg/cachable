//
//  Storage.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation


extension CachableManager {

    /// Storage class
    public class Storage {

        /// Shared Instance
        public static var shared = Storage()

        internal func createCacheRecord(forKey: String, filePath: String, expireDuration: TimeInterval) throws {
            let cachRecord = CachableRecord.init(filePath: filePath, key: forKey, cachedAt: Date().timeIntervalSince1970, expireDuration: expireDuration)
            do {
                var currentRecords = try getCacheRecords()
                currentRecords.removeAll { $0.key == forKey }
                currentRecords.append(cachRecord)
                try saveCacheRecords(records: currentRecords)
            } catch {
                throw error
            }
        }


        /// Used to update the expireDuration of a cacheRecord, in case it changes dynamically.
        ///
        /// - Parameters:
        ///   - newExpireDuration: new duration in seconds
        ///   - forKey: key for the cache item
        internal func updateCacheRecordExpireDuration(newExpireDuration: TimeInterval, forKey: String) {
            do {
                var cacheRecords = try getCacheRecords()

                for (index, record) in cacheRecords.enumerated() {
                    if record.key == forKey {
                        cacheRecords[index].expireDuration = newExpireDuration
                    }
                }

                let encoded = try JSONEncoder().encode(cacheRecords)
                UserDefaults.standard.set(encoded, forKey: "Cachable-cache-records")

            } catch {
                Logger.log(message: "Cannot update record for \(forKey)")
            }
        }

        /// Gets all records for cached items
        ///
        /// - Returns: Array of CacheRecords
        /// - Throws: Error
        internal func getCacheRecords() throws -> [CachableRecord] {
            if let cacheRecordsData = UserDefaults.standard.data(forKey: "Cachable-cache-records") {
                do {
                    let decoded = try JSONDecoder().decode([CachableRecord].self, from: cacheRecordsData)
                    return decoded
                } catch {
                    throw error
                }
            }
            return [CachableRecord]()
        }

        /// Get a single cacheRecord for the given item
        ///
        /// - Parameter key: key for cached item
        /// - Returns: Single CacheRecord instance
        /// - Throws: Error / CachableError
        internal func getCacheRecordFor(key: String) throws -> CachableRecord {
            if let cacheRecordsData = UserDefaults.standard.data(forKey: "Cachable-cache-records") {
                do {
                    let decoded = try JSONDecoder().decode([CachableRecord].self, from: cacheRecordsData)
                    let possibleRecords = decoded.filter { $0.key == key}
                    if let record = possibleRecords.first {

                        if !isCacheRecordExpired(record: record) {
                            print("record not expired, return from cache")
                            return record
                        } else {
                            if CachableManager.isOfflineModeEnabled {
                                print("record expired but offlineMode is enabled")
                                return record
                            }
                            print("record expired")
                            throw CachableManager.Errors.cacheRecordExpired
                        }
                    }
                    print("no results")
                    throw CachableManager.Errors.noResults

                } catch {
                    print(error)
                    throw error
                }
            }
            throw CachableManager.Errors.noResults
        }

        /// Check to see if a cacheRecord is expired
        ///
        /// - Parameter record: the CacheRecord in question
        /// - Returns: Bool
        internal func isCacheRecordExpired(record: CachableRecord) -> Bool {
            let currentTimeStamp = Date().timeIntervalSince1970
            let expireTimeStamp = record.cachedAt + record.expireDuration
            return expireTimeStamp < currentTimeStamp
        }

        /// Saves caches records to disk
        ///
        /// - Parameter records: An array of CacheRecords that will be saved
        /// - Throws: Error / CachableError
        internal func saveCacheRecords(records: [CachableRecord]) throws {
            guard let url = CachableManager.Storage.CacheDirectory.documents.url else {
                print("no url or file not found")
                throw CachableManager.Errors.noResults
            }
            do {
                let encoded = try JSONEncoder().encode(records)
                UserDefaults.standard.set(encoded, forKey: "Cachable-cache-records")
                let filePath = url.appendingPathComponent("cachable-records", isDirectory: false)
                do {

                    if FileManager.default.fileExists(atPath: filePath.path) {
                        try FileManager.default.removeItem(atPath: filePath.path)
                    }
                    FileManager.default.createFile(atPath: filePath.path, contents: encoded, attributes: nil)

                } catch {
                    print("Cachable", error.localizedDescription)
                    throw CachableManager.Errors.failedToSave
                }
            } catch {
                throw error
            }
        }


        /// Removes all cached items, from both documents and cache directories
        ///
        /// - Throws: Error
        public func removeAllCache() throws {
            do {
                let cacheRecords = try getCacheRecords()
                for record in cacheRecords {
                    try removeFromDisk(filePath: record.filePath)
                }
            } catch {
                throw error
            }
        }


        /// Removes only expired cached items; This will not allow you to use them for offline mode
        ///
        /// - Throws: Error
        /// - TODO: Create remove function that will remove unsed cache after a specified period; need to add `lastUsed` key
        public func removeExpiredCache() throws {
            do {
                var updatedCacheRecords = [CachableRecord]()
                let cacheRecords = try getCacheRecords()
                for record in cacheRecords {
                    let currentTimeStamp = Date().timeIntervalSinceNow
                    let expireTimeStamp = record.cachedAt + record.expireDuration
                    if expireTimeStamp <= currentTimeStamp {
                        try removeFromDisk(filePath: record.filePath)
                        print("Removed expired cache", record.key)
                    } else {
                        updatedCacheRecords.append(record)
                    }
                }

                if updatedCacheRecords.count != cacheRecords.count {
                    let encoded = try JSONEncoder().encode(updatedCacheRecords)
                    UserDefaults.standard.set(encoded, forKey: "Cachable-cache-records")
                    print("updated cache records")
                }

            } catch {
                throw error
            }
        }



        /// Save an item to disk
        ///
        /// - Parameters:
        ///   - codable: item to save
        ///   - forKey: key to store the item under
        ///   - expireDuration: how long til the cache expires, in seconds
        ///   - directory: the directory the item should be stored under
        /// - Throws: Error / CachableError
//        internal func writeToDisk<T:Codable>(codable: T, forKey: String, expireDuration: TimeInterval,  directory: CachableManager.Storage.CacheDirectory = .caches) throws {
//
//            guard let url = directory.url else {
//                throw CachableManager.Errors.directoryNotFound
//            }
//
//            let filePath = url.appendingPathComponent(forKey, isDirectory: false)
//            do {
//                let data = try JSONEncoder().encode(codable)
//                if FileManager.default.fileExists(atPath: filePath.path) {
//                    try FileManager.default.removeItem(atPath: filePath.path)
//                }
//                FileManager.default.createFile(atPath: filePath.path, contents: data, attributes: nil)
//                try createCacheRecord(codable: codable, forKey: forKey, filePath: filePath.path, expireDuration: expireDuration)
//
//            } catch {
//                print("Cachable", error.localizedDescription)
//                throw CachableManager.Errors.failedToSave
//            }
//        }


        internal func writeToDisk(data: Data, forKey: String, expireDuration: TimeInterval,  directory: CachableManager.Storage.CacheDirectory = .caches) throws {

            guard let url = directory.url else {
                throw CachableManager.Errors.directoryNotFound
            }

            let filePath = url.appendingPathComponent(forKey, isDirectory: false)
            do {
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try FileManager.default.removeItem(atPath: filePath.path)
                }
                FileManager.default.createFile(atPath: filePath.path, contents: data, attributes: nil)
                try createCacheRecord(forKey: forKey, filePath: filePath.path, expireDuration: expireDuration)

            } catch {
                print("Cachable", error.localizedDescription)
                throw CachableManager.Errors.failedToSave
            }
        }


        internal func readFromDisk(request: URLRequest, directory: CachableManager.Storage.CacheDirectory = .caches) throws -> Data {
            guard let url = directory.url else {
                print("no url or file not found")
                throw CachableManager.Errors.noResults
            }

            do {
                let _ = try CachableManager.Storage.shared.getCacheRecordFor(key: request.uuid)
                let filePath = url.appendingPathComponent(request.uuid, isDirectory: false)
                if let data = FileManager.default.contents(atPath: filePath.path) {
                    return data
                } else {
                    print("file not found")
                    throw CachableManager.Errors.fileNotFound
                }
            } catch {
                throw error
            }
        }


        /// Read a cached item from disk
        ///
        /// - Parameters:
        ///   - readable: Type the item should be decoded to
        ///   - forKey: key to retreive the item
        ///   - directory: the directory the item should be stored under
        /// - Returns: the Item type passed in
        /// - Throws: Error / CachableError
        internal func readFromDisk<T:Codable>(readable: T.Type, forKey: String, directory: CachableManager.Storage.CacheDirectory = .caches) throws -> T {
            guard let url = directory.url else {
                print("no url or file not found")
                throw CachableManager.Errors.noResults
            }

            do {
                let _ = try CachableManager.Storage.shared.getCacheRecordFor(key: forKey)
                let filePath = url.appendingPathComponent(forKey, isDirectory: false)
                if let data = FileManager.default.contents(atPath: filePath.path) {
                    do {
                        let decodable = try JSONDecoder().decode(readable, from: data)
                        return decodable
                    } catch {
                        print(error)
                        throw CachableManager.Errors.failedToDecode
                    }
                } else {
                    print("file not found")
                    throw CachableManager.Errors.fileNotFound
                }
            } catch {
                throw error
            }
        }


        /// Remove file from disk
        ///
        /// - Parameter filePath: file location
        /// - Throws: Error
        internal func removeFromDisk(filePath: String) throws {
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch {
                    throw error
                }
            }
        }


    }
}
