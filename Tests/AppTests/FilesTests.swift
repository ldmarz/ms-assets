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


final class FileTests: XCTestCase {
    let filesURL = "/api/files/"
    var app: Application!
    var conn: PostgreSQLConnection!
    var url =  "http://ldmarz.com"
    var typeFile = "PNG"
    var asoc = "ms-account"
    var someHash = "insert some nice hash here!"

    
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testFilesCanBeRetrievedFromAPI() throws {
        let file = try Files.create(url: url, typeFile: typeFile, asoc: asoc, hash: someHash, on: conn)
        _ = try Files.create(on: conn)
        let files = try app.getResponse(to: filesURL, decodeTo: [Files].self)
        
         XCTAssertEqual(files.count, 2)
         XCTAssertEqual(files[0].id, file.id)
         XCTAssertEqual(files[0].url, file.url)
         XCTAssertEqual(files[0].typeFile, file.typeFile)
         XCTAssertEqual(files[0].asoc, file.asoc)
    }
    
    func testFileCanBeSavedFromPreSignedAPI() throws {
        let file = Files(url: url, typeFile: typeFile, asoc: asoc)

        let savedFile = try app.getResponse(
            to: "\(filesURL)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: file,
            decodeTo: Files.self)
        
        XCTAssertEqual(savedFile.url, url)
        XCTAssertEqual(savedFile.typeFile, typeFile)
        XCTAssertEqual(savedFile.asoc, asoc)
        XCTAssertEqual(savedFile.hash, "") // HASH is optional by preSignedAPI...
    }
}
