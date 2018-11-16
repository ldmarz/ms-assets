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
    var hash: String?
    
    init(url: String, typeFile: String, asoc: String, hash: String = "") {
        self.url = url
        self.typeFile = typeFile
        self.asoc = asoc
        self.hash = hash
    }
    
    init(filesParams: FilesParams) {
        self.url = filesParams.url
        self.typeFile = filesParams.typeFile
        self.asoc = filesParams.asoc
        self.hash? = filesParams.hash
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

extension Files: PostgreSQLUUIDModel {}
extension Files: Parameter {}
extension Files: Migration {}
extension Files: Content {}
