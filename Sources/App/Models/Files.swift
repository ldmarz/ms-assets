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
    var hash: String
    var typeFile: String
    var asoc: String
    
    init(url: String, hash: String, typeFile: String, asoc: String) {
        self.url = url
        self.hash = hash
        self.typeFile = typeFile
        self.asoc = asoc
    }
}

extension Files: PostgreSQLUUIDModel {}
extension Files: Parameter {}
extension Files: Migration {}
extension Files: Content {}
