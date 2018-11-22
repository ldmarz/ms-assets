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
import S3

final class FileTests: XCTestCase {
    let filesURL = "/api/files/"
    var app: Application!
    var conn: PostgreSQLConnection!
    let url =  "http://ldmarz.com"
    let typeFile = "PNG"
    let asoc = "ms-account"
    let someNiceName = "name"
    let someNiceHash = "someHash"

    
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testFilesCanBeRetrievedFromAPI() throws {
        let file = try Files.create(url: url, typeFile: typeFile, asoc: asoc, hash: someNiceHash, on: conn)
        _ = try Files.create(on: conn)
        let files = try app.getResponse(to: filesURL, decodeTo: [Files].self)
        
         XCTAssertEqual(files.count, 2)
         XCTAssertEqual(files[0].id, file.id)
         XCTAssertEqual(files[0].url, file.url)
         XCTAssertEqual(files[0].typeFile, file.typeFile)
         XCTAssertEqual(files[0].asoc, file.asoc)
    }
    
    func testWeCanTestWithPlayMinio() throws{
        let result = try Files.manuallyUploadToMinio()
        let consulting = try Files.manuallyCheckIfExistFileOnMinio()
        let delete = try Files.manuallyDeleteFileFromMinio()
        
        XCTAssertEqual(result, "done")
        XCTAssertEqual(consulting, "hi")
        XCTAssertEqual(delete, "done")
    }
    
    
    func testFileCanBeSavedFromPreSignedAPI() throws {
        let _ = try Files.manuallyUploadToMinio()
        let file = Files(url: url, name: fileName, typeFile: typeFile, asoc: asoc, hash: someNiceHash)

        let savedFile = try app.getResponse(
            to: "\(filesURL)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: file,
            decodeTo: Files.self)
        
        XCTAssertEqual(savedFile.url, url)
        XCTAssertEqual(savedFile.typeFile, typeFile)
        XCTAssertEqual(savedFile.asoc, asoc)
        try Files.cleanMinioBuckets()
    }
    
    func testGettingASingleFileFromUser() throws {
        let file = try Files.create(url: url, name: someNiceName, typeFile: typeFile, asoc: asoc, hash: someNiceHash, on: conn)
        _ = try Files.create(on: conn)
        
        let recivedFile = try app.getResponse(
            to: "\(filesURL)\(file.id!)",
            decodeTo: Files.self)
        
        XCTAssertEqual(recivedFile.url, file.url)
        XCTAssertEqual(recivedFile.typeFile, file.typeFile)
        XCTAssertEqual(recivedFile.asoc, file.asoc)
    }
    
    func testGettingMultiplesFilesByIds() throws {
        let file1 = try Files.create(url: url, name: someNiceName, typeFile: typeFile, asoc: asoc, hash: someNiceHash, on: conn)
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
        let file1 = try Files.create(url: url, name: someNiceName, typeFile: typeFile, asoc: newAsoc, hash: someNiceHash, on: conn)
        let file2 = try Files.create(url: "\(url)2", typeFile: "\(typeFile)2", asoc: newAsoc, on: conn)
        _ = try Files.create(on: conn)
        
        let recivedFile = try app.getResponse(
            to: "\(filesURL)?asoc=in:\(file1.asoc),\(file2.asoc)",
            decodeTo: [Files].self
        )
        
        XCTAssertEqual(recivedFile.count, 2)
    }
    
    func testDeletingFile() throws {
        let _ = try Files.manuallyUploadToMinio()
        let file1 = try Files.create(url: url, name: fileName, typeFile: typeFile, asoc: asoc, hash: someNiceHash, on: conn)
        _ = try Files.create(on: conn)
        var s3Error = ""
        
        let _ = try app.sendRequest(
            to: "\(filesURL)\(file1.id!.uuidString)",
            method: .DELETE
        )
        
        let files = try app.getResponse(to: filesURL, decodeTo: [Files].self)

        do {
            let _ = try Files.manuallyCheckIfExistFileOnMinio()
        } catch {
            s3Error = error.s3ErroMessage()!.message
        }


        XCTAssertEqual("The specified key does not exist.", s3Error)
        XCTAssertEqual(files.count, 1)
        try Files.cleanMinioBuckets()
    }
    
    func testCannotSavedTwoFilesWithTheSameHash() throws {
        let uniqueHash = "hello World !!"
        let file = Files(url: url, name: someNiceName, typeFile: typeFile, asoc: asoc, hash: uniqueHash)
        let _ = try Files.create(url: "\(url)2", typeFile: "\(typeFile)2", asoc: asoc, hash: uniqueHash, on: conn)
        
        let savedFile = try app.getResponse(
            to: "\(filesURL)",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: file,
            decodeTo: errorResponse.self)
        
        XCTAssertEqual(savedFile.error, true)
        XCTAssertEqual(savedFile.reason, "File already saved")
    }
}
