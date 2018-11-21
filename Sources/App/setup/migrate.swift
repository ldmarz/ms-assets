//
//  migrate.swift
//  App
//
//  Created by Lenin Martinez on 11/21/18.
//

import Fluent
import Vapor

public func migrate(config: inout MigrationConfig) {
    config.add(model: Files.self, database: .psql)
    config.add(migration: AddHashUniqueIndex.self, database: .psql)
}
