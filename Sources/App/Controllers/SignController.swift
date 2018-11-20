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
    
    
    func preSignedUrl(_ req: Request) throws -> UrlSignedResponse {
        let s3 = try req.makeS3Signer()
        
        guard let fileName = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest)
        }
        
        // TODO: this can be in a constans file
        let url = self.generateURL(minioHost: "http://localhost:9000", bucket: "un-bucket", fileName: fileName)

        guard
            let signedURL = try s3.presignedURL(for: .PUT, url: url!, expiration: Expiration.custom(604800))
            else { throw Abort(.badRequest) }
        return UrlSignedResponse(url: signedURL.absoluteString)
    }
    
    func generateURL(minioHost: String, bucket: String, fileName: String) -> URL? {
        return URL(string: "\(minioHost)/\(bucket)/\(fileName)")
    }
}

struct UrlSignedResponse: Content {
    var url: String
}
