//
//  NetworkUtilities.swift
//
//  Created by Danny Schnabel on 2022-06-23.
//

import Combine
import Foundation

enum NetworkSessionError: LocalizedError {
    case invalidReponse(URLResponse)
    case invalidStatus(HTTPURLResponse)
    case invalidImageData(Data)

    var errorDescription: String? {
        switch self {
        case .invalidStatus(let response):  return "Invalid HTTP response \(response.statusCode), \(response)"
        case .invalidReponse(let response): return "Expected an HTTP response, got \(response)"
        case .invalidImageData:             return "Not image data."
        }
    }
}

@available(iOS 13, *)
extension Publisher {
    // This modifies a publisher to catch a NetworkSessionError and if it is the right sort to justify
    // retrying the publisher, with delays. Note that the peculiarities of combine's Publishers.Delay and
    // .retry means that right now, the first retry occurs without the delay (once an error is caught).
    // Also, that first retry occurs without being counted in the number passed to .retry, which is why
    // this modifier passes 'retries - 1'.
    func failOrRetry<T, E>(_ retryInfo: ClearCoreSDK.RetryInfo) -> Publishers.TryCatch<Self, AnyPublisher<T, E>>
            where T == Self.Output, E == Self.Failure {
        tryCatch { error -> AnyPublisher<T, E> in
            if let theError = error as? NetworkSessionError {
                switch theError {
                case .invalidStatus(let httpResponse):
                    if let retries = retryInfo.noOfRetries, retries > 0 {
                        if retryInfo.retryStatusCode?.contains(httpResponse.statusCode) == true {
                            let interval = RunLoop.SchedulerTimeType.Stride(TimeInterval(retryInfo.retryDelay ?? 0))
                            return Publishers.Delay(upstream: self,
                                                    interval: interval,
                                                    tolerance: 1,
                                                    scheduler: RunLoop.main)
                                        .retry(retries - 1)
                                        .eraseToAnyPublisher()
                        }
                    }

                case .invalidReponse:   throw error
                case .invalidImageData: throw error
                }
            }
            throw error
        }
    }
}

extension URLSession: NetworkSession {
    public var ccConfiguration: URLSessionConfiguration { self.configuration }

    @available(iOS 13, *)
    public func ccDataTaskPublisher(for request: URLRequest) -> AnyPublisher<DataTaskOutput, URLError> {
        return self.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

public extension URLRequest {
    /// Enumeration of URL request methods.
    enum Method: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }

    init(url: URL,
         cachePolicy: Foundation.URLRequest.CachePolicy,
         timeoutInterval: Foundation.TimeInterval,
         method: Method,
         headers: [String: String]? = nil,
         bodyData: Data? = nil) {
            self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
            self.httpMethod = method.rawValue
            self.httpBody = bodyData
            self.allHTTPHeaderFields = headers
    }
}

public extension URLComponents {
    init(_ base: URLComponents, additionalPathComponents path: String?, queryItems: [URLQueryItem]?) {
        self = base
        if let path = path {
            self.path.append("/")
            self.path.append(path)
        }
        self.queryItems = queryItems
    }

    var apiURL: URL {
        guard let url = url else {
            assert(false, "no url?")
            return URL(fileURLWithPath: "")
        }
        return url
    }
}
