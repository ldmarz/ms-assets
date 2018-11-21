//
//  s3.swift
//  App
//
//  Created by Lenin Martinez on 11/21/18.
//

import Foundation
import S3

public let temporallyBucket = Environment.get("TEMPORALLY_BUCKET", "un-bucket")
public let finalBucket = Environment.get("FINAL_BUCKET", "otro-bucket")
public let minio_hostname = Environment.get("MINIO_HOSTNAME", "127.0.0.1:9000")
public let usingTLS = Environment.get("TLS", false) ? true : false

extension Region {
    public init ?(rawValue: String, hostName: String, useTLS: Bool) {
        guard let name = RegionName(rawValue: rawValue) else {
            return nil
        }
        
        self.init(name: name, hostName: hostName, useTLS: useTLS)
    }
}

public func getS3Service() throws -> S3Signer.Config {
    let region = Region(
        rawValue: Environment.get("MINIO_REGION", "us-east-1"),
        hostName: minio_hostname,
        useTLS: usingTLS)
    
    return S3Signer.Config(
        accessKey: Environment.get("ACCESS_KEY", "36J9X8EZI4KEV1G7EHXA"),
        secretKey: Environment.get("SECRET_KEY", "ECk2uqOoNqvtJIMQ3WYugvmNPL_-zm3WcRqP5vUM"),
        region: region!
    )
}
