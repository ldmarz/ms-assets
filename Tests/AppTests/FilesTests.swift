//
//  FilesTests.swift
//  App
//
//  Created by Lenin Martinez on 11/13/18.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL


final class UserTests: XCTestCase {
    let filesURL = "/api/files/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testFilesCanBeRetrievedFromAPI() throws {
//        let file = try Files.create(name: usersName, username: usersUsername, on: conn)
        _ = try Files.create(on: conn)
        let files = try app.getResponse(to: filesURL, decodeTo: [Files].self)
        
        XCTAssertEqual(files.count, 1)
        // XCTAssertEqual(files[0].name, filesName)
        // XCTAssertEqual(files[0].username, filesUsername)
        // XCTAssertEqual(files[0].id, user.id)
    }
}
