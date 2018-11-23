import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.register(collection: FilesController())
    try router.register(collection: SignController())
    try router.register(collection: DocsController())
}
