import Foundation
import Vapor
import FluentPostgreSQL

struct AddHashUniqueIndex: PostgreSQLMigration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Files.self, on: conn) { builder in
            builder.unique(on: \.hash)
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.update(Files.self, on: conn) { builder in
            builder.deleteUnique(from: \.hash)
        }
    }
}
