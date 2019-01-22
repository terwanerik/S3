//
//  S3+Put.swift
//  S3
//
//  Created by Ondrej Rafaj on 01/12/2016.
//  Copyright © 2016 manGoweb UK Ltd. All rights reserved.
//

import Foundation
import Vapor


// Helper S3 extension for uploading files by their URL/path
public extension S3 {
    
    // MARK: Upload
    
    /// Upload file to S3
    public func put(file: S3File.Upload, headers: [String: String], on container: Container) throws -> EventLoopFuture<S3File.Response> {
        let builder = urlBuilder(for: container)
        let url = try builder.url(file: file)
        
//        let url = URL(string: "https://s3.eu-west-2.amazonaws.com/s3-liveui-test/file-hu.txt")!
        
        var awsHeaders: [String: String] = headers
        awsHeaders["content-type"] = file.mime.description
        awsHeaders["x-amz-acl"] = file.access.rawValue
        let headers = try signer.headers(for: .PUT, urlString: url.absoluteString, headers: awsHeaders, payload: Payload.bytes(file.data))
        
        let request = Request(using: container)
        request.http.method = .PUT
        request.http.headers = headers
        request.http.body = HTTPBody(data: file.data)
        request.http.url = url
        let client = try container.make(Client.self)
        return client.send(request).map(to: S3File.Response.self) { response in
            try self.check(response)
            let res = S3File.Response(data: file.data, bucket: file.bucket ?? self.defaultBucket, path: file.path, access: file.access, mime: file.mime)
            return res
        }
    }
    
    /// Upload file to S3
    public func put(file: S3File.Upload, on container: Container) throws -> EventLoopFuture<S3File.Response> {
        return try put(file: file, headers: [:], on: container)
    }
    
    /// Upload file by it's URL to S3
    public func put(file url: URL, destination: String, access: AccessControlList = .privateAccess, on container: Container) throws -> Future<S3File.Response> {
        let data: Data = try Data(contentsOf: url)
        let file = S3File.Upload(data: data, bucket: nil, destination: destination, access: access, mime: mimeType(forFileAtUrl: url))
        return try put(file: file, on: container)
    }
    
    /// Upload file by it's path to S3
    public func put(file path: String, destination: String, access: AccessControlList = .privateAccess, on container: Container) throws -> Future<S3File.Response> {
        let url: URL = URL(fileURLWithPath: path)
        return try put(file: url, destination: destination, bucket: nil, access: access, on: container)
    }
    
    /// Upload file by it's URL to S3, full set
    public func put(file url: URL, destination: String, bucket: String?, access: AccessControlList = .privateAccess, on container: Container) throws -> Future<S3File.Response> {
        let data: Data = try Data(contentsOf: url)
        let file = S3File.Upload(data: data, bucket: bucket, destination: destination, access: access, mime: mimeType(forFileAtUrl: url))
        return try put(file: file, on: container)
    }
    
    /// Upload file by it's path to S3, full set
    public func put(file path: String, destination: String, bucket: String?, access: AccessControlList = .privateAccess, on container: Container) throws -> Future<S3File.Response> {
        let url: URL = URL(fileURLWithPath: path)
        return try put(file: url, destination: destination, bucket: bucket, access: access, on: container)
    }
    
}
