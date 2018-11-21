//
//  Files.swift
//  App
//
//  Created by Lenin Martinez on 11/13/18.
//

import Foundation
import Vapor
import FluentPostgreSQL
import S3

final class Files: Codable {
    var id: UUID?
    var url: String
    var name: String
    var typeFile: String
    var asoc: String
    var hash: String
    
    var createdAt: Date?
    var updatedAt: Date?

    init(url: String, name: String, typeFile: String, asoc: String, hash: String) {
        self.url = url
        self.typeFile = typeFile
        self.asoc = asoc
        self.name = name
        self.hash = hash
    }
    
    init(filesParams: FilesParams) {
        self.url = filesParams.url
        self.typeFile = filesParams.typeFile
        self.asoc = filesParams.asoc
        self.name = filesParams.name
        self.hash = filesParams.hash
    }
}

struct FilesParams: Content {
    var id: UUID?
    var url: String
    var name: String
    var typeFile: String
    var asoc: String
    var hash: String
    var file: Vapor.File
}

extension Files: PostgreSQLUUIDModel {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt

}

extension Files: Parameter {}
extension Files: Migration {}
extension Files: Content {}

extension Future where T == Files {
    func deleteFileInBucket(_ req: Request) throws -> Future<Files> {
        let s3 = try req.makeS3Client()
        return flatMap { file in
            return try s3.delete(file: file.name, on: req)
                .map { return file }
        }
    }
    
    func deleteFileInDatabase(_ req: Request) throws -> Future<Void> {
        return flatMap { file in
            return file.delete(on: req)
        }
    }
}

extension Files {
    static func checkIfExistByHash(_ req: Request, fileToBeenSave: Files) throws -> Future<Files?> {
        return Files.query(on: req)
            .filter(\.hash == fileToBeenSave.hash)
            .first()
    }
}

