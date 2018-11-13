//
//  models+Tetable.swift
//  App
//
//  Created by Lenin Martinez on 11/13/18.
//

import Foundation
@testable import App
import FluentPostgreSQL

extension Files {
    static func create(url: String = "someNiceUrl", hash: String = "123qeqwe1dq", typeFile: String = ".png", asoc: String = "ms-account", on connection: PostgreSQLConnection) throws -> Files {
        let file = Files(url: url, hash: hash, typeFile: typeFile, asoc: asoc)
        return try file.save(on: connection).wait()
    }
}