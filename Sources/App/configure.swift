import Vapor
import FluentPostgreSQL
import S3


/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    /// Register aws dependencie
    let s3Client = S3Signer.Config(
        accessKey: "AKIAIOSFODNN7EXAMPLE",
        secretKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        region: Region(name: .usEast1,
                       hostName: "127.0.0.1:9000",
                       useTLS: false
                )
        )
    try services.register(s3: s3Client, defaultBucket: "")
    
    /// Register the configured PostgreSql database to the database config.
    var databases = DatabasesConfig()
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: Environment.get("HOST") ?? "localhost",
        username: Environment.get("USERNAME") ?? "postgres",
        database: Environment.get("DATABASE") ?? "files",
        password: Environment.get("PASSWORD") ?? "123456")
    let database = PostgreSQLDatabase(config: databaseConfig)
    
    databases.add(database: database, as: .psql)
    databases.enableLogging(on: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Files.self, database: .psql)
    services.register(migrations)
    
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}
