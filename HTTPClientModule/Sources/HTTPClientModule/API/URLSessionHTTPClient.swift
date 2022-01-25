//
//  URLSessionHTTPClient.swift
//  
//
//  Created by Muzammil Peer on 23/01/2022.
//
//https://www.swiftbysundell.com/articles/http-post-and-file-upload-requests-using-urlsession/

import Foundation

public final class URLSessionHTTPClient {
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
}

extension URLSessionHTTPClient : HTTPClient
{
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
    
    public func post<T:Codable>(from url: URL, codableRequestBody:T, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return self.commonHTTPOperationWithCodable(method: "POST", from: url, codableRequestBody: codableRequestBody, completion: completion)
    }
    
    public func put<T:Codable>(from url: URL,codableRequestBody:T, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return self.commonHTTPOperationWithCodable(method: "PUT", from: url, codableRequestBody: codableRequestBody, completion: completion)
    }
    
    public func delete<T:Codable>(from url: URL,codableRequestBody:T, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        return self.commonHTTPOperationWithCodable(method: "DELETE", from: url, codableRequestBody: codableRequestBody, completion: completion)
    }
    
    //multi part
    public func postMultiPartData<T:Codable>(from url: URL ,binaryData: Data?,codableRequestBody:T?, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        var request:URLRequest = self.generateURLRequest(from: url)
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        "application/octet-stream"
        
        let httpBody = NSMutableData()
        
        do {
            if let codableRequest:T = codableRequestBody {
                let encoder = JSONEncoder()
                let body:Data = try encoder.encode(codableRequest)
                if let formFields:[String : Any] = try JSONSerialization.jsonObject(with: body, options: .mutableContainers) as? [String : Any]
                {
                    for (key, value) in formFields {
                        httpBody.appendString(convertFormField(named: key, value: value as! String, using: boundary))
                    }
                }
            }
        } catch {}

        if let binData:Data = binaryData {
            httpBody.append(convertFileData(fieldName: "file_field",
                                               fileName: "file.bin",
                                               mimeType: "application/octet-stream",
                                               fileData: binData,
                                               using: boundary))
        }

        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data
        
        let task = session.uploadTask(
            with: request,
            from:httpBody as Data,
            completionHandler: { data, response, error in
                // Validate response and call handler
                completion(Result {
                    if let error = error {
                        throw error
                    } else if let data = data, let response = response as? HTTPURLResponse {
                        return (data, response)
                    } else {
                        throw UnexpectedValuesRepresentation()
                    }
                })
            }
        )
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
    
    public func postMultiPartFile(from url: URL ,fileURL: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        var request:URLRequest = self.generateURLRequest(from: url)
        request.httpMethod = "POST"

        let task = session.uploadTask(
            with: request,
            fromFile: fileURL,
            completionHandler: { data, response, error in
                // Validate response and call handler
                completion(Result {
                    if let error = error {
                        throw error
                    } else if let data = data, let response = response as? HTTPURLResponse {
                        return (data, response)
                    } else {
                        throw UnexpectedValuesRepresentation()
                    }
                })
            }
        )
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}

extension URLSessionHTTPClient {
    
    private func generateURLRequest(from url: URL) -> URLRequest
    {
        return URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
    }
    
    private func commonHTTPOperationWithCodable<T:Codable>(method:String,from url: URL,codableRequestBody:T, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask
    {
        // To ensure that our request is always sent, we tell
        // the system to ignore all local cache data:
        var request:URLRequest = self.generateURLRequest(from: url)
        request.httpMethod = method
        do {
            let encoder = JSONEncoder()
            let body:Data = try encoder.encode(codableRequestBody)
//                params = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : Any]
            request.httpBody = body
        } catch {}

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(
            with: request,
            completionHandler: { data, response, error in
                // Validate response and call handler
                completion(Result {
                    if let error = error {
                        throw error
                    } else if let data = data, let response = response as? HTTPURLResponse {
                        return (data, response)
                    } else {
                        throw UnexpectedValuesRepresentation()
                    }
                })

            }
        )

        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
   
    
    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
      let data = NSMutableData()

      data.appendString("--\(boundary)\r\n")
      data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
      data.appendString("Content-Type: \(mimeType)\r\n\r\n")
      data.append(fileData)
      data.appendString("\r\n")

      return data as Data
    }

    private func convertFormField(named name: String, value: String, using boundary: String) -> String {
      var fieldString = "--\(boundary)\r\n"
      fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
      fieldString += "\r\n"
      fieldString += "\(value)\r\n"

      return fieldString
    }
   
}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
