//
//  HTTPClient.swift
//  
//
//  Created by Muzammil Peer on 23/01/2022.
//
import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func post<T:Codable>(from url: URL,codableRequestBody:T, completion: @escaping (Result) -> Void) -> HTTPClientTask
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func put<T:Codable>(from url: URL,codableRequestBody:T, completion: @escaping (Result) -> Void) -> HTTPClientTask
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func delete<T:Codable>(from url: URL,codableRequestBody:T, completion: @escaping (Result) -> Void) -> HTTPClientTask
    
    
    //Multipart
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @available(*,deprecated, renamed: "postMultiPartFile", message: "Please use new method - postMultiPartFile to upload large files. b/c postMultiPartData can not upload large files as it uses string manupulation.")
    @discardableResult
    func postMultiPartData<T:Codable>(from url: URL ,binaryData: Data?,codableRequestBody:T?, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask


    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func postMultiPartFile(from url: URL ,fileURL: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask

}
