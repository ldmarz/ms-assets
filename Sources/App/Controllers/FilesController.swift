import Vapor
import Fluent
import Multipart
import S3
import Foundation
import Crypto


/// Controls basic CRUD operations on `Files`s.
final class FilesController: RouteCollection {
    func boot(router: Router) throws {
         let filesRoutes = router.grouped("api", "files")
        
        filesRoutes.post(Files.self, use: save)
        filesRoutes.get(use: getAll)
        
        filesRoutes.post(FilesParams.self, at: "upload", use: upload)
        filesRoutes.get("buckets", use: getBuckets)
    }
    
    func getAll(_ req: Request) throws -> Future<[Files]> {
        return Files.query(on: req).all()
    }
    
    func save(_ req: Request, fileToBeenSave: Files) throws -> Future<Files> {
        return fileToBeenSave.save(on: req)
    }

    func upload(_ req: Request, uploadFile: FilesParams) throws -> Future<Files> {
        let s3 = try req.makeS3Client()
        let fileToUpload = File.Upload(data: uploadFile.file.data, bucket: "un-bucket", destination: uploadFile.url)
        let hashFromFile = try self.hashFile(file: uploadFile.file.data)

        return try s3.put(file: fileToUpload, on: req)
            .flatMap { result in
                return Files(url: result.path, typeFile: result.mime, asoc: uploadFile.asoc, hash: hashFromFile)
                    .save(on: req)
        }
    }
    
    func hashFile(file: Data) throws -> String {
        return try SHA256.hash(file).hexEncodedString().lowercased()
    }
    
    func getBuckets(_ req: Request) throws -> Future<BucketsInfo> {
        let s3 = try req.makeS3Client()
        return try s3.buckets(on: req)
    }
}
