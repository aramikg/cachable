//
//  Storage.swift
//  Cachable
//
//  Created by aramik on 9/8/19.
//  Copyright © 2019 aramik. All rights reserved.
//

import Foundation


extension Cachable {
    public class Storage {
        public static var shared = Storage()

        internal func createCacheRecord<T:Codable>(codable: T, forKey: String, filePath: String, expireDuration: TimeInterval) throws {
            let netstoreRecord = CachableRecord.init(filePath: filePath, key: forKey, cachedAt: Date().timeIntervalSince1970, expireDuration: expireDuration)

            do {
                var currentRecords = try getCacheRecords()
                currentRecords.removeAll { $0.key == forKey }
                currentRecords.append(netstoreRecord)
                try saveCacheRecords(records: currentRecords)
            } catch {
                throw error
            }
        }

        internal func getCacheRecords() throws -> [CachableRecord] {
            if let cacheRecordsData = UserDefaults.standard.data(forKey: "netstore-cache-records") {
                do {
                    let decoded = try JSONDecoder().decode([CachableRecord].self, from: cacheRecordsData)
                    return decoded
                } catch {
                    throw error
                }
            }
            return [CachableRecord]()
        }

        internal func getCacheRecordFor(key: String) throws -> CachableRecord {
            if let cacheRecordsData = UserDefaults.standard.data(forKey: "netstore-cache-records") {
                do {
                    let decoded = try JSONDecoder().decode([CachableRecord].self, from: cacheRecordsData)
                    let possibleRecords = decoded.filter { $0.key == key}
                    if let record = possibleRecords.first {

                        if !isCacheRecordExpired(record: record) {
                            print("record not expired, return from cache")
                            return record
                        } else {
                            if Netstore.offlineMode {
                                print("record expired but offlineMode is enabled")
                                return record
                            }
                            print("record expired")
                            throw Netstore.Errors.cacheRecordExpired
                        }
                    }
                    print("no results")
                    throw Netstore.Errors.noResults

                } catch {
                    print(error)
                    throw error
                }
            }
            throw Netstore.Errors.noResults
        }

        internal func isCacheRecordExpired(record: CachableRecord) -> Bool {
            let currentTimeStamp = Date().timeIntervalSince1970
            let expireTimeStamp = record.cachedAt + record.expireDuration
            return expireTimeStamp < currentTimeStamp
        }

        internal func saveCacheRecords(records: [CachableRecord]) throws {
            do {
                let encoded = try JSONEncoder().encode(records)
                UserDefaults.standard.set(encoded, forKey: "netstore-cache-records")
            } catch {
                throw error
            }
        }

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
                    UserDefaults.standard.set(encoded, forKey: "netstore-cache-records")
                    print("updated cache records")
                }

            } catch {
                throw error
            }
        }



        public func writeToDisk<T:Codable>(codable: T, forKey: String, expireDuration: TimeInterval,  directory: Netstore.Storage.CacheDirectory = .caches) throws {

            guard let url = directory.url else {
                throw Netstore.Errors.directoryNotFound
            }

            let filePath = url.appendingPathComponent(forKey, isDirectory: false)
            do {
                let data = try JSONEncoder().encode(codable)
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try FileManager.default.removeItem(atPath: filePath.path)
                }
                FileManager.default.createFile(atPath: filePath.path, contents: data, attributes: nil)
                try createCacheRecord(codable: codable, forKey: forKey, filePath: filePath.path, expireDuration: expireDuration)

            } catch {
                print("Netstore", error.localizedDescription)
                throw Netstore.Errors.failedToSave
            }
        }



        public func readFromDisk<T:Codable>(readable: T.Type, forKey: String, directory: Netstore.Storage.CacheDirectory = .caches) throws -> T {
            guard let url = directory.url else {
                print("no url or file not found")
                throw Netstore.Errors.noResults
            }

            do {
                let _ = try Netstore.Storage.shared.getCacheRecordFor(key: forKey)
                let filePath = url.appendingPathComponent(forKey, isDirectory: false)
                if let data = FileManager.default.contents(atPath: filePath.path) {
                    do {
                        let decodable = try JSONDecoder().decode(readable, from: data)
                        return decodable
                    } catch {
                        print(error)
                        throw Netstore.Errors.failedToDecode
                    }
                } else {
                    print("file not found")
                    throw Netstore.Errors.fileNotFound
                }
            } catch {
                throw error
            }
        }

        public func removeFromDisk(filePath: String) throws {
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
