//
//  SignController.swift
//  App
//
//  Created by Lenin Martinez on 11/15/18.
//
import Vapor
import Foundation
import SimpleStorageSigner
import S3

final class SignController: RouteCollection {
    func boot(router: Router) throws {
        let SignRoutes = router.grouped("api", "sign")
        
        
        SignRoutes.get("presignedUrl", use: preSignedUrl)
    }
    
    
    func preSignedUrl(_ req: Request) throws -> String {
        let s3 = try req.makeS3Signer()
        
        let url = URL(string: "http://localhost:9000/un-bucket/1_0AA8gnq8dOPvta")!

        guard
              let signedURL = try s3.presignedURL(for: .PUT, url: url, expiration: Expiration.custom(604800))
            else { throw Abort(.badRequest) }
        return signedURL.absoluteString
    }
}
