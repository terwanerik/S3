//
//  S3+ObjectInfo.swift
//  S3
//
//  Created by Ondrej Rafaj on 12/05/2018.
//

import Foundation
import Vapor
import S3Signer


// Helper S3 extension for working with buckets
public extension S3 {
    
    // MARK: Buckets
    
    /// Get acl file information (ACL)
    /// https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGETacl.html
    public func get(acl file: LocationConvertible, headers: [String: String], on container: Container) throws -> Future<S3File.Info> {
        fatalError("Not implemented")
    }
    
    /// Get acl file information
    /// https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGETacl.html
    func get(acl file: LocationConvertible, on container: Container) throws -> Future<S3File.Info> {
        return try get(fileInfo: file, headers: [:], on: container)
    }
    
    /// Get file information (HEAD)
    /// https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectHEAD.html
    public func get(fileInfo file: LocationConvertible, headers: [String: String], on container: Container) throws -> Future<S3File.Info> {
        let builder = urlBuilder(for: container)
        let url = try builder.url(file: file)
        
        let headers = try signer.headers(for: .HEAD, urlString: url.absoluteString, headers: headers, payload: .none)
        return try make(request: url, method: .HEAD, headers: headers, data: emptyData(), on: container).map(to: S3File.Info.self) { response in
            try self.check(response)
            
            let bucket = file.bucket ?? self.defaultBucket
            let region = file.region ?? self.signer.config.region
            let mime = response.http.headers.string(S3File.Info.CodingKeys.mime.rawValue)
            let size = response.http.headers.int(S3File.Info.CodingKeys.size.rawValue)
            let server = response.http.headers.string(S3File.Info.CodingKeys.server.rawValue)
            let etag = response.http.headers.string(S3File.Info.CodingKeys.etag.rawValue)
            let expiration = response.http.headers.date(S3File.Info.CodingKeys.expiration.rawValue)
            let created = response.http.headers.date(S3File.Info.CodingKeys.created.rawValue)
            let modified = response.http.headers.date(S3File.Info.CodingKeys.modified.rawValue)
            let versionId = response.http.headers.string(S3File.Info.CodingKeys.versionId.rawValue)
            let storageClass = response.http.headers.string(S3File.Info.CodingKeys.storageClass.rawValue)
            
            let info = S3File.Info(bucket: bucket, region: region, path: file.path, access: .authenticatedRead, mime: mime, size: size, server: server, etag: etag, expiration: expiration, created: created, modified: modified, versionId: versionId, storageClass: storageClass)
            return info
        }
    }
    
    /// Get file information (HEAD)
    /// https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectHEAD.html
    func get(fileInfo file: LocationConvertible, on container: Container) throws -> Future<S3File.Info> {
        return try get(fileInfo: file, headers: [:], on: container)
    }
    
}
