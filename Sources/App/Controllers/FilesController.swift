import Vapor
import Fluent
import Multipart
import S3
import Foundation


/// Controls basic CRUD operations on `Files`s.
final class FilesController: RouteCollection {
    func boot(router: Router) throws {
         let filesRoutes = router.grouped("api", "files")
        
        filesRoutes.post(Files.self, use: upload)
        filesRoutes.get("buckets", use: getBuckets)
        filesRoutes.get(use: getAll)
    }
    
    /// Returns a list of all `Files`s.
    func getAll(_ req: Request) throws -> Future<[Files]> {
        return Files.query(on: req).all()
    }
    
    func upload(_ req: Request, uploadFile: Files) throws -> Future<String> {
        let s3 = try req.makeS3Client()
        let algo = File.Upload(data: uploadFile.file.data, bucket: "un-bucket", destination: uploadFile.url)
        
        return try s3.put(file: algo, on: req)
            .map(to: String.self) { result in
                let json = try JSONEncoder().encode(result)
                return String(data: json, encoding: .utf8) ?? "Unknown content!"
        }
    }
    
    func getBuckets(_ req: Request) throws -> Future<BucketsInfo> {
        let s3 = try req.makeS3Client()
        return try s3.buckets(on: req)
    }

    /// Saves a decoded `Files` to the database.
    func create(_ req: Request, file: Files) throws -> Future<Files> {
        return file.save(on: req)
    }
}
