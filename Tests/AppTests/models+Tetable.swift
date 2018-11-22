//
//  models+Tetable.swift
//  App
//
//  Created by Lenin Martinez on 11/13/18.
//

import Foundation
@testable import App
import FluentPostgreSQL
import S3
import Vapor

public let fileName = "someFile"

extension Files {
    static func create(url: String = "someNiceUrl", name: String = "niceName", typeFile: String = ".png", asoc: String = "ms-account", hash: String = UUID().uuidString, on connection: PostgreSQLConnection) throws -> Files {
        let file = Files(url: url, name: name, typeFile: typeFile, asoc: asoc, hash: hash)
        return try file.save(on: connection).wait()
    }
    
    static func manuallyUploadToMinio() throws -> String {
        let someFile = Data([0x68, 0x69])
        let fileToUpload = File.Upload(data: someFile, bucket: temporallyBucket, destination: fileName) // Creating struct to upload
        
        let s3Client = try Application.testable().makeS3Client()
        
        return try s3Client.put(file: fileToUpload, on: Application.testable())
            .map(to: String.self) { result in
                return "done"
        }.wait()
    }
    
    static func manuallyDeleteFileFromMinio(bucket: String = temporallyBucket) throws -> String {
        let s3Client = try Application.testable().makeS3Client()
        let location = File.Location(path: fileName, bucket: bucket)

        return try s3Client.delete(file: location, on: Application.testable())
            .map(to: String.self) { result in
                return "done"
            }.wait()
    }
    
    static func manuallyCheckIfExistFileOnMinio() throws -> String {
        let s3Client = try Application.testable().makeS3Client()
        let location = File.Location(path: fileName, bucket: temporallyBucket)
        
        return try s3Client.get(file: location, on: Application.testable())
            .map(to: String.self) { result in
                return String(data: result.data, encoding: String.Encoding.utf8)!
            }
            .wait()
    }
    
    static func cleanMinioBuckets() throws {
        let _ = try Files.manuallyDeleteFileFromMinio(bucket: temporallyBucket)
        let _ = try Files.manuallyDeleteFileFromMinio(bucket: finalBucket)
    }
}
