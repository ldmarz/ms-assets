//
//  SignController.swift
//  App
//
//  Created by Lenin Martinez on 11/15/18.
//
import Vapor
import Foundation
import S3

final class SignController: RouteCollection {
    func boot(router: Router) throws {
        let SignRoutes = router.grouped("api", "sign")
        
        
        SignRoutes.get("presignedUrl", use: preSignedUrl)
    }
    
    
    func preSignedUrl(_ req: Request) throws -> String {
        let s3 = try req.makeS3Signer()
        //        TODO: change this for urlComponents https://medium.com/swift2go/building-safe-url-in-swift-using-urlcomponents-and-urlqueryitem-alfian-losari-510a7b1f3c7e
        let url = URL(string: "http://localhost:9000/un-bucket/1_0AA8gnq8dOPvta")!

        guard
              let signedURL = try s3.presignedURL(for: .PUT, url: url, expiration: Expiration.custom(604800))
            else { throw Abort(.badRequest) }
        return signedURL.absoluteString
    }
}
