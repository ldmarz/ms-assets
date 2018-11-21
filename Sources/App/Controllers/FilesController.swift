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
        filesRoutes.delete(Files.parameter, use: delete)
    }
    
    func index(_ req: Request) throws -> Future<[Files]> {
        let criteria: [FilterOperator<Files.Database, Files>] = try [
            req.filter(\Files.id, at: "id"),
            req.filter(\Files.asoc, at: "asoc"),
            ].compactMap { $0 }
        
         let sort: [Files.Database.QuerySort] = try [
             req.sort(\Files.createdAt, as: "createdAt")
             ].compactMap { $0 }
    
        
        return Files
            .find(by: criteria, sortBy: sort, on: req)
    }
    
    func getFileById(_ req: Request) throws -> Future<Files> {
        return try req.parameters.next(Files.self)
    }
    
    func save(_ req: Request, fileToBeenSave: Files) throws -> Future<Files> {
        return try Files
            .checkIfExistByHash(req, fileToBeenSave: fileToBeenSave)
            .ifExistCopyFileToPersistenceBucket(req, fileToBeenSave: fileToBeenSave)
            .removeOldFile(req)
            .flatMap(to: Files.self) { fileByHash in
                return fileToBeenSave.save(on: req)
            }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Files.self)
            .deleteFileInBucket(req)
            .deleteFileInDatabase(req)
            .transform(to: HTTPStatus.ok)
        }

    func hashFile(file: Data) throws -> String {
        return try SHA256.hash(file).hexEncodedString().lowercased()
    }
    
    // This func is for manually upload file
    func upload(_ req: Request, uploadFile: FilesParams) throws -> Future<Files> {
        let s3 = try req.makeS3Client()
        let fileToUpload = File.Upload(data: uploadFile.file.data, bucket: temporallyBucket, destination: uploadFile.url) // Creating struct to upload
        
        return try s3.put(file: fileToUpload, on: req)
            .flatMap { result in
                return Files(url: result.path, name: uploadFile.name, typeFile: result.mime, asoc: uploadFile.asoc, hash: uploadFile.hash)
                    .save(on: req)
        }
    }
}
