//
//  SignTests.swift
//  App
//
//  Created by Lenin Martinez on 11/20/18.
//

@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class SignTests: XCTestCase {
    var app: Application!
    var signController = SignController()
    let signURL = "/api/sign/"
    let minioHost = "http://localhost:9000"
    let bucket = "un-bucket"
    let nameFile = "1_0AA8gnq8dOPvta"
    let expectedURL = "http://localhost:9000/un-bucket/1_0AA8gnq8dOPvta"
    
    struct algo: Content {}
    
    override func setUp() {
        app = try! Application.testable()
    }

    func testCreateURL() throws {
        let generatedURL = signController.generateURL(minioHost: minioHost, bucket: bucket, fileName: nameFile)
        XCTAssertEqual(generatedURL?.absoluteString, expectedURL)
    }
    
    func testCanCreateURLFromAPI() throws {
        let files = try app.getResponse(to: "\(signURL)presignedUrl?name=niceName", decodeTo: UrlSignedResponse.self)
        XCTAssertEqual(files.url.count, 309)
    }
}
