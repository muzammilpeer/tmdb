//
//  SharedTestHelpers.swift
//  
//
//  Created by Muzammil Peer on 24/01/2022.
//
import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {///movie/{movie_id}/rating
    return URL(string: "https://api.themoviedb.org/3/movie/550/rating?api_key=a9dfed6dd4d408d46105886b9064d3f9")!
}
private var baseURL: URL {
    return URL(string: "https://7a94e1a1-0a1e-4f44-b281-878ad929c059.mock.pstmn.io/")!
}
func absoluteServerURL(uri:String) -> URL {
    return URL(string: "\(baseURL.absoluteString)\(uri)")!
}
var anyLocalFileURL:URL {
    let bundle = Bundle.module
    return bundle.url(forResource: "SampleFile", withExtension: "jpg", subdirectory: "Resources")!
}

//var anyFruitItem:RemoteFruitItem {
//    return RemoteFruitItem.init(id: nil, name: "Orange", color: "orange", image: nil)
//}

func anyData() -> Data {
    return Data("any data".utf8)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}
