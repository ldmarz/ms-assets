//
//  Files.swift
//  App
//
//  Created by Lenin Martinez on 11/13/18.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class Files: Codable {
    var id: UUID?
    var url: String
    var typeFile: String
    var asoc: String
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    init(url: String, typeFile: String, asoc: String) {
        self.url = url
        self.typeFile = typeFile
        self.asoc = asoc
    }
    
    init(filesParams: FilesParams) {
        self.url = filesParams.url
        self.typeFile = filesParams.typeFile
        self.asoc = filesParams.asoc
    }
}

struct FilesParams: Content {
    var id: UUID?
    var url: String
    var hash: String
    var typeFile: String
    var asoc: String
    var file: File
}

extension Files: PostgreSQLUUIDModel {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var deletedAtKey: TimestampKey? = \.deletedAt
    static var updatedAtKey: TimestampKey? = \.updatedAt

}

extension Files: Parameter {}
extension Files: Migration {}
extension Files: Content {}
