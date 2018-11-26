//
//  migrate.swift
//  App
//
//  Created by Lenin Martinez on 11/21/18.
//

import Vapor

public func getCorsMiddleware() -> CORSMiddleware {
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .DELETE, .PUT],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    return CORSMiddleware(configuration: corsConfiguration)
}
