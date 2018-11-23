//
//  docsController.swift
//  App
//
//  Created by Lenin Martinez on 11/23/18.
//
import Vapor
import Foundation

final class DocsController: RouteCollection {
    func boot(router: Router) throws {
        let DocsRoutes = router.grouped("api", "docs")
        
        DocsRoutes.get(use: index)
    }
    
    func index(req: Request) throws -> Future<String> {
        return try req.fileio().read(file: "/Users/leninmartinez/Documents/sandbox/vapor/handling-files/Public/swagger.yml")
            .map(to: String.self) { result in
                print (result)
                let dataContent = String(data: result, encoding: String.Encoding.utf8)!
                print(dataContent)
                return dataContent
            }
    }
}
