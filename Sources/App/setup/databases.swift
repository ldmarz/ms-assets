//
//  databases.swift
//  App
//
//  Created by Lenin Martinez on 11/21/18.
//

import Foundation
import FluentPostgreSQL
import Vapor

public func databases(config: inout DatabasesConfig) throws {
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: Environment.get("HOST") ?? "localhost",
        username: Environment.get("USERNAME") ?? "postgres",
        database: Environment.get("DATABASE") ?? "files",
        password: Environment.get("PASSWORD") ?? "123456")

    let FilesDB = PostgreSQLDatabase(config: databaseConfig)
    config.add(database: FilesDB, as: .psql)
    
    if Environment.get("DATABASE_LOGS", false) {
        config.enableLogging(on: .psql)
    }
}
