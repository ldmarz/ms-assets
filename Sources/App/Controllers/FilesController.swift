import Vapor
import Fluent

/// Controls basic CRUD operations on `Files`s.
final class FilesController: RouteCollection {
    func boot(router: Router) throws {
         let filesRoutes = router.grouped("api", "files")
        
        filesRoutes.get(use: getAll)
    }
    
    /// Returns a list of all `Files`s.
    func getAll(_ req: Request) throws -> Future<[Files]> {
        return Files.query(on: req).all()
    }

    /// Saves a decoded `Files` to the database.
    func create(_ req: Request, file: Files) throws -> Future<Files> {
        return file.save(on: req)
    }
}
