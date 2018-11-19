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
    var someNiceName = "name"

    
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testFilesCanBeRetrievedFromAPI() throws {
        let file = try Files.create(url: url, typeFile: typeFile, asoc: asoc, on: conn)
        _ = try Files.create(on: conn)
        let files = try app.getResponse(to: filesURL, decodeTo: [Files].self)
        
         XCTAssertEqual(files.count, 2)
         XCTAssertEqual(files[0].id, file.id)
         XCTAssertEqual(files[0].url, file.url)
         XCTAssertEqual(files[0].typeFile, file.typeFile)
         XCTAssertEqual(files[0].asoc, file.asoc)
    }
    
    func testFileCanBeSavedFromPreSignedAPI() throws {
        let file = Files(url: url, name: someNiceName, typeFile: typeFile, asoc: asoc)

        let savedFile = try app.getResponse(
            to: "\(filesURL)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: file,
            decodeTo: Files.self)
        
        XCTAssertEqual(savedFile.url, url)
        XCTAssertEqual(savedFile.typeFile, typeFile)
        XCTAssertEqual(savedFile.asoc, asoc)
    }
    
    func testGettingASingleFileFromUser() throws {
        let file = try Files.create(url: url, name: someNiceName, typeFile: typeFile, asoc: asoc, on: conn)
        _ = try Files.create(on: conn)
        
        let recivedFile = try app.getResponse(
            to: "\(filesURL)\(file.id!)",
            decodeTo: Files.self)
        
        XCTAssertEqual(recivedFile.url, file.url)
        XCTAssertEqual(recivedFile.typeFile, file.typeFile)
        XCTAssertEqual(recivedFile.asoc, file.asoc)
    }
    
    func testGettingMultiplesFilesByIds() throws {
        let file1 = try Files.create(url: url, name: someNiceName, typeFile: typeFile, asoc: asoc, on: conn)
        let file2 = try Files.create(url: "\(url)2", typeFile: "\(typeFile)2", asoc: asoc, on: conn)
        _ = try Files.create(on: conn)
        
        let recivedFile = try app.getResponse(
            to: "\(filesURL)?id=in:\(file1.id!.uuidString),\(file2.id!.uuidString)",
            decodeTo: [Files].self
        )
        
        XCTAssertEqual(recivedFile.count, 2)
    }
    
    
    func testGettingMultiplesFilesByAsoc() throws {
        let newAsoc = "my_new_asco"
        let file1 = try Files.create(url: url, name: someNiceName, typeFile: typeFile, asoc: newAsoc, on: conn)
        let file2 = try Files.create(url: "\(url)2", typeFile: "\(typeFile)2", asoc: newAsoc, on: conn)
        _ = try Files.create(on: conn)
        
        let recivedFile = try app.getResponse(
            to: "\(filesURL)?asoc=in:\(file1.asoc),\(file2.asoc)",
            decodeTo: [Files].self
        )
        
        XCTAssertEqual(recivedFile.count, 2)
    }
    
    func testDeletingFile() throws {
        let file1 = try Files.create(url: url, name: someNiceName, typeFile: typeFile, asoc: asoc, on: conn)
        _ = try Files.create(on: conn)
        
        let _ = try app.sendRequest(
            to: "\(filesURL)\(file1.id!.uuidString)",
            method: .DELETE
        )
        
        let files = try app.getResponse(to: filesURL, decodeTo: [Files].self)
        
        XCTAssertEqual(files.count, 1)
    }
}
