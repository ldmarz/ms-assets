import Vapor
import FluentPostgreSQL
import S3
import VaporExt

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Load .env file
    Environment.dotenv()

    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    
    // CORS Midleware
    middlewares.use(getCorsMiddleware())
    
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    
    services.register(middlewares)
    
    /// Register aws dependencie
    try services.register(s3: getS3Service(), defaultBucket: temporallyBucket)
    
    /// Register databases.
    var databasesConfig = DatabasesConfig()
    try databases(config: &databasesConfig)
    services.register(databasesConfig)

    /// Register migrations
    var migrationsConfig = MigrationConfig()
    migrate(config: &migrationsConfig)
    services.register(migrationsConfig)
    
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}
