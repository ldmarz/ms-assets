import Vapor
import Fluent
import Multipart
import S3
import Foundation
import Crypto
import VaporExt


/// Controls basic CRUD operations on `Files`s.
final class FilesController: RouteCollection {
    func boot(router: Router) throws {
         let filesRoutes = router.grouped("api", "files")
        
        filesRoutes.post(Files.self, use: save)
        filesRoutes.get(use: index)
        filesRoutes.get(Files.parameter, use: getFileById)
        
        filesRoutes.post(FilesParams.self, at: "upload", use: upload)
    }
    
    func index(_ req: Request) throws -> Future<[Files]> {
        
        let criteria: [FilterOperator<Files.Database, Files>] = try [
            req.filter(\Files.id, at: "id"),
            req.filter(\Files.asoc, at: "asoc"),
            ].compactMap { $0 }
        
//         var sort: [Files.Database.QuerySort] = try [
//             req.sort(\Files.createdAt, as: "createdAt")
//             ].compactMap { $0 }
    
        
        return Files
            .find(by: criteria, on: req)
    }
    
    func getFileById(_ req: Request) throws -> Future<Files> {
        return try req.parameters.next(Files.self)
    }
    
    func save(_ req: Request, fileToBeenSave: Files) throws -> Future<Files> {
        return fileToBeenSave.save(on: req)
    }

    func hashFile(file: Data) throws -> String {
        return try SHA256.hash(file).hexEncodedString().lowercased()
    }
    
    func upload(_ req: Request, uploadFile: FilesParams) throws -> Future<Files> {
        let s3 = try req.makeS3Client()
        let fileToUpload = File.Upload(data: uploadFile.file.data, bucket: "un-bucket", destination: uploadFile.url)
        
        return try s3.put(file: fileToUpload, on: req)
            .flatMap { result in
                return Files(url: result.path, typeFile: result.mime, asoc: uploadFile.asoc)
                    .save(on: req)
        }
    }
}
