//
//  CCNetworkManager.swift
//
//  Created by Danny Schnabel on 2022-03-07.
//

import Combine
import Foundation

public extension ClearCoreSDK {

    /// A ``NetworkManager`` can maintain a dictionary of base URLs to simplify the way that URLs
    /// are composed and specified for requests. This type encapsulates the dictionary.
    typealias BaseURLDictionary = [String: URLComponents]

    /// This is the standard structure for a request response.
    struct NetworkResponse {
        static var empty: NetworkResponse { NetworkResponse(headerFields: [:], data: nil) }

        public let headerFields: [String: String]
        public let data: Data?
    }

    /// This maintains network request retry information. All requests have been set up to accept
    /// a RetryInfo object and if it is not provided, to default to the basic RetryInfo() object,
    /// which results in no retrying of request.
    ///
    /// The three properties maintained in this struct are: `noOfRetries`, the number of retries to attempt;
    /// `retryStatusCodes`, an array of http response status codes whose appearance warrants retrying; and
    /// `retryDelay`, the number of seconds between retries.
    struct RetryInfo {
        var noOfRetries: Int?
        var retryStatusCode: [Int]?
        var retryDelay: Int?

        /// A basic initialization of a `RetryInfo` object.
        /// - Parameters:
        ///   - retryDelay: The number of seconds between retries. This is optional and defaults to zero,
        ///   i.e. no delay between retries.
        ///   - retryStatusCode: An array of http response status codes whose appearance warrants retrying.
        ///   This is optional and defaults to an empty array, resulting in no retries, regardless of the
        ///   value of noOfRetries.
        ///   - noOfRetries: The number of retries to attempt. This is optional and defaults to zero.
        public init(retryDelay: Int = 0, retryStatusCode: [Int] = [], noOfRetries: Int = 0) {
            self.noOfRetries = noOfRetries
            self.retryStatusCode = retryStatusCode
            self.retryDelay = retryDelay
        }
    }

    /// NetworkManager provides all the basic functionality to make network and API calls.
    ///
    /// A NetworkManager provides a number of different `requestPublisher` and `getRequestPublisher` methods for
    ///  API interaction. All of them return some form of a `URLSession` `DataTaskPublisher`, which will publish
    ///  once on receiving a response from a URLSession dataTask.
    ///
    /// A NetworkManager can be initialized with a `BaseURLDictionary` which can allow (short) string-key access
    /// to URLComponents so that the request publisher method specifications can be simplified. An application
    /// will typically only make request from a limited number of API endpoints and these can all be set into the
    /// NetworkManager `BaseURLDictionary` once, in one place, thereby simplifying the process of updating endpoints.
    ///
    /// A NetworkManager can also be initialized with a default `JSONDecoder` if the application GET requests all
    /// require the same custom `JSONDecoder`. The `getRequestPublisher` methods can of course all override this
    /// default `JSONDecoder` if necessary. If the default decoder is not specified at initialization, the default
    /// default is the standard `JSONDecoder`.
    ///
    /// **Note** that the ClearCore Network Manager publishers are defined in the Combine framework and hence the
    /// Network Manager requires the iOS version to be 13 or later.
    struct NetworkManager {
        let clearCoreSDK: ClearCoreSDK
        let session: NetworkSession      // NetworkSession functions as a wrapper around URLSession

        // NetworkManager can maintain a dictionary of base URLs to simplify the
        // way URLs are composed and specified for requests.
        let baseURLs: BaseURLDictionary?

        // The following default can be set on initializing the network manager
        // if an API requires a custom decoder.
        let defaultDecoder: JSONDecoder
        let retryValues: RetryInfo

        /// Default basic initialization
        public init() {
            self.clearCoreSDK = ClearCoreSDK()
            self.session = URLSession.shared
            self.defaultDecoder = JSONDecoder()
            self.baseURLs = nil
            self.retryValues = RetryInfo()
        }

        /// Initialize with a custom NetworkSession which might be a configured URLSession
        /// or something else designed specifically for testing.
        /// - Parameters:
        ///   - session: A `NetworkSession`.
        ///   - baseURLs: An optional `BaseURLDictionary` so request can access URLs with a key.
        ///   - defaultDecoder: A custom default `JSONDecoder` to use if the getRequest does not specify a decoder.
        ///   (This is optional and defaults to the standard `JSONDecoder`).
        ///   - forTests: Boolean to indicate if this is being used for Unit Tests.
        public init(session: NetworkSession = URLSession.shared,
                    baseURLs: BaseURLDictionary? = nil,
                    defaultDecoder: JSONDecoder = JSONDecoder(),
                    forTests: Bool = false) {
            self.clearCoreSDK = ClearCoreSDK(forTests: forTests)
            self.session = session
            self.baseURLs = baseURLs
            self.defaultDecoder = defaultDecoder
            self.retryValues = RetryInfo()
        }

        /// Initialize with session configuration parameters.
        /// - Parameters:
        ///   - baseURLs: An optional `BaseURLDictionary` so request can access URLs with a key.
        ///   - defaultDecoder: A custom default `JSONDecoder` to use if the getRequest does not specify a decoder.
        ///   (This is optional and defaults to the standard `JSONDecoder`).
        ///   - defaultCachePolicy: An optional `URLRequest.CachePolicy` for the `URLSessionConfiguration`
        ///   for the  ``NetworkSession``.
        ///   - defaultTimeoutInterval: An optional timeout interval for the `URLSessionConfiguration`
        ///   for the  ``NetworkSession``.
        ///   - forTests: Boolean to indicate if this is being used for Unit Tests.
        public init(baseURLs: BaseURLDictionary? = nil,
                    defaultDecoder: JSONDecoder = JSONDecoder(),
                    defaultCachePolicy: Foundation.URLRequest.CachePolicy? = nil,
                    defaultTimeoutInterval: Foundation.TimeInterval? = nil,
                    forTests: Bool = false) {

            let sessionConfig = URLSessionConfiguration.default
            if let defaultCachePolicy = defaultCachePolicy {
                sessionConfig.requestCachePolicy = defaultCachePolicy
            }
            if let defaultTimeoutInterval = defaultTimeoutInterval {
                sessionConfig.timeoutIntervalForRequest = defaultTimeoutInterval
            }
            self.clearCoreSDK = ClearCoreSDK(forTests: forTests)
            self.session = URLSession(configuration: sessionConfig)
            self.baseURLs = baseURLs
            self.defaultDecoder = defaultDecoder
            self.retryValues = RetryInfo()
        }

        /// A basic request publisher creator accepting a `URLRequest`.
        /// - Parameters:
        ///   - urlRequest: A `URLRequest` object.
        ///   - otherValidStatusCodes: An optional array of status codes that will be accepted as indications.
        ///   - retryBehaviour: An optional `RetryInfo` object containing the request retry characteristics.
        ///   of a valid response.
        /// - Returns: A `NetworkResponse` publisher.
        @available(iOS 13, *)
        public func requestPublisher(urlRequest: URLRequest,
                                     otherValidStatusCodes: [Any]? = nil,
                                     retryBehaviour: RetryInfo = RetryInfo()) -> AnyPublisher<NetworkResponse, Error> {
            clearCoreSDK.ccLog("requestPublisher method called.")
            return session.ccDataTaskPublisher(for: urlRequest)
                        .tryMap {(data: Data, response: URLResponse) in
                                try self.validateResponse(response, otherValidStatusCodes: otherValidStatusCodes)
                                let headers = (response as? HTTPURLResponse)?.allHeaderFieldsStrings ?? [:]
                                return NetworkResponse(headerFields: headers, data: data)
                            }
                        .failOrRetry(retryBehaviour)
                        .receive(on: RunLoop.main)
                        .eraseToAnyPublisher()
        }

        /// Basic request publisher creator accepting a URL as a `String` and additional parameters.
        /// - Parameters:
        ///   - urlString: The request URL as a `String`.
        ///   - method: The request method.
        ///   - cachePolicy: An optional `URLRequest.CachePolicy` object.
        ///   - timeoutInterval: An optional request time-out `Double`.
        ///   - otherValidStatusCodes: An optional array of status codes that will be accepted as indications
        ///   of a valid response.
        ///   - retryBehaviour: An optional `RetryInfo` object containing the request retry characteristics.
        ///   - headers: The request headers.
        ///   - bodyData: The request body.
        /// - Returns: A `NetworkResponse` publisher.
        @available(iOS 13, *)
        public func requestPublisher(urlString: String,
                                     method: URLRequest.Method,
                                     cachePolicy: Foundation.URLRequest.CachePolicy? = nil,
                                     timeoutInterval: Foundation.TimeInterval? = nil,
                                     otherValidStatusCodes: [Any]? =  nil,
                                     retryBehaviour: RetryInfo = RetryInfo(),
                                     headers: [String: String]? = nil,
                                     bodyData: Data? = nil) -> AnyPublisher<NetworkResponse, Error> {

            guard let apiURL = URL(string: urlString) else {
                clearCoreSDK.ccLog("urlString does not generate a URL")
                assert(false)
                return Result { NetworkResponse.empty }.publisher.eraseToAnyPublisher()
            }

            let request = URLRequest(url: apiURL,
                            cachePolicy: cachePolicy ?? session.ccConfiguration.requestCachePolicy,
                            timeoutInterval: timeoutInterval ?? session.ccConfiguration.timeoutIntervalForRequest,
                            method: method,
                            headers: headers,
                            bodyData: bodyData)

            return requestPublisher(urlRequest: request,
                                    otherValidStatusCodes: otherValidStatusCodes,
                                    retryBehaviour: retryBehaviour)
        }

        /// Request publisher creator that utilizes the NetworkManager baseURL dictionary.
        /// - Parameters:
        ///   - baseURLKey: A `String` key corresponding to a `BaseURLDictionary` entry.
        ///   - additionalPathComponents: An optional `String` to augment the base URL from the dictionary.
        ///   - queryItems: An optional array of `URLQueryItem`s.
        ///   - method: The request method.
        ///   - cachePolicy: A `URLRequest.CachePolicy` object.
        ///   - timeoutInterval: An optional request time-out `Double`.
        ///   - otherValidStatusCodes: An optional array of status codes that will be accepted as indications
        ///   of a valid response.
        ///   - retryBehaviour: An optional `RetryInfo` object containing the request retry characteristics.
        ///   - headers: The request headers.
        ///   - bodyData: The request body.
        /// - Returns: A `NetworkResponse` publisher.
        @available(iOS 13, *)
        public func requestPublisher(baseURLKey: String,
                                     additionalPathComponents: String? = nil,
                                     queryItems: [URLQueryItem]? = nil,
                                     method: URLRequest.Method,
                                     cachePolicy: Foundation.URLRequest.CachePolicy? = nil,
                                     timeoutInterval: Foundation.TimeInterval? = nil,
                                     otherValidStatusCodes: [Any]? = nil,
                                     retryBehaviour: RetryInfo = RetryInfo(),
                                     headers: [String: String]? = nil,
                                     bodyData: Data? = nil) -> AnyPublisher<NetworkResponse, Error> {

            guard let baseURLs = baseURLs, let baseURL = baseURLs[baseURLKey] else {
                clearCoreSDK.ccLog("baseURLKey not found in baseURL dictionary")
                assert(false)
                return Result { NetworkResponse.empty }.publisher.eraseToAnyPublisher()
            }
            let fullURL = URLComponents(baseURL,
                                        additionalPathComponents: additionalPathComponents,
                                        queryItems: queryItems)
            let request = URLRequest(url: fullURL.apiURL,
                            cachePolicy: cachePolicy ?? session.ccConfiguration.requestCachePolicy,
                            timeoutInterval: timeoutInterval ?? session.ccConfiguration.timeoutIntervalForRequest,
                            method: method,
                            headers: headers,
                            bodyData: bodyData)

            return requestPublisher(urlRequest: request,
                                    otherValidStatusCodes: otherValidStatusCodes,
                                    retryBehaviour: retryBehaviour)
        }

        /// Return a publisher which publishes the decoded (parsed) result of a basic GET request.
        /// To get data without decoding or data that includes response header information, use a
        /// `requestPublisher()` method with request method set as `URLRequest.Method.get`.
        /// - Parameters:
        ///   - urlRequest: A `URLRequest` object.
        ///   - otherValidStatusCodes: An optional array of status codes that will be accepted as indications
        ///   of a valid response.
        ///   - retryBehaviour: An optional `RetryInfo` object containing the request retry characteristics.
        ///   - responseType: An example of the type of response that is expected.
        ///   It must conform to the ``NetworkDecodedResponse`` protocol.
        ///   - customDecoder: An optional custom default `JSONDecoder` to use on the response.
        ///   If this is not provided, the decoder will default to the NetworkManager's default decoder.
        /// - Returns: A publisher that publishes a response matching the `responseType`.
        @available(iOS 13, *)
        public func getRequestPublisher<Response: NetworkDecodedResponse>(
                        urlRequest: URLRequest,
                        otherValidStatusCodes: [Any]? = nil,
                        retryBehaviour: RetryInfo = RetryInfo(),
                        responseType: Response,
                        customDecoder: JSONDecoder? = nil) -> AnyPublisher<Response, Error> {
            clearCoreSDK.ccLog("getRequestPublisher method called.")
            let decoder = customDecoder ?? defaultDecoder
            return session.ccDataTaskPublisher(for: urlRequest)
                        .tryMap {(data: Data, response: URLResponse) in
                                try self.validateResponse(response, otherValidStatusCodes: otherValidStatusCodes)
                                return data
                            }
                        .failOrRetry(retryBehaviour)
                        .decode(type: Response.self, decoder: decoder)
                        .receive(on: RunLoop.main)
                        .eraseToAnyPublisher()
        }

        /// Return a publisher which publishes the decoded (parsed) result of a basic GET request.
        /// To get data without decoding or data that includes response header information, use a
        /// `requestPublisher()` method with request method set as `URLRequest.Method.get`.
        /// - Parameters:
        ///   - urlString: The request URL as a `String`.
        ///   - cachePolicy: An optional `URLRequest.CachePolicy` object.
        ///   - timeoutInterval: An optional request time-out `Double`.
        ///   - otherValidStatusCodes: An optional array of status codes that will be accepted as indications
        ///   of a valid response.
        ///   - retryBehaviour: An optional `RetryInfo` object containing the request retry characteristics.
        ///   - headers: The request headers.
        ///   - bodyData: The request body.
        ///   - responseType: An example of the type of response that is expected.
        ///   It must conform to the ``NetworkDecodedResponse`` protocol.
        ///   - customDecoder: An optional custom default `JSONDecoder` to use on the response.
        ///   If this is not provided, the decoder will default to the NetworkManager's default decoder.
        /// - Returns: A publisher that publishes a response matching the `responseType`.
        @available(iOS 13, *)
        public func getRequestPublisher<Response: NetworkDecodedResponse>(
                        urlString: String,
                        cachePolicy: Foundation.URLRequest.CachePolicy? = nil,
                        timeoutInterval: Foundation.TimeInterval? = nil,
                        otherValidStatusCodes: [Any]? = nil,
                        retryBehaviour: RetryInfo = RetryInfo(),
                        headers: [String: String]? = nil,
                        bodyData: Data? = nil,
                        responseType: Response,
                        customDecoder: JSONDecoder? = nil) -> AnyPublisher<Response, Error> {

            guard let apiURL = URL(string: urlString) else {
                clearCoreSDK.ccLog("urlString does not generate a URL")
                assert(false)
                return Result { Response.empty }.publisher.eraseToAnyPublisher()
            }

            let request = URLRequest(url: apiURL,
                            cachePolicy: cachePolicy ?? session.ccConfiguration.requestCachePolicy,
                            timeoutInterval: timeoutInterval ?? session.ccConfiguration.timeoutIntervalForRequest,
                            method: .get,
                            headers: headers,
                            bodyData: bodyData)

            return getRequestPublisher(urlRequest: request,
                        otherValidStatusCodes: otherValidStatusCodes,
                        retryBehaviour: retryBehaviour,
                        responseType: responseType,
                        customDecoder: customDecoder)
        }

        /// Return a publisher which publishes the decoded (parsed) result of a basic GET request.
        /// To get data without decoding or data that includes response header information, use a
        /// `requestPublisher()` method with request method set as `URLRequest.Method.get`.
        /// - Parameters:
        ///   - baseURLKey: A `String` key corresponding to a `BaseURLDictionary` entry.
        ///   - additionalPathComponents: An optional `String` to augment the base URL from the dictionary.
        ///   - queryItems: An optional array of `URLQueryItem`s.
        ///   - cachePolicy: An optional `URLRequest.CachePolicy` object.
        ///   - timeoutInterval: An optional request time-out `Double`.
        ///   - otherValidStatusCodes: An optional array of status codes that will be accepted as indications
        ///   of a valid response.
        ///   - retryBehaviour: An optional `RetryInfo` object containing the request retry characteristics.
        ///   - headers: The request headers.
        ///   - bodyData: The request body.
        ///   - responseType: An example of the type of response that is expected.
        ///   It must conform to the ``NetworkDecodedResponse`` protocol.
        ///   - customDecoder: An optional custom default `JSONDecoder` to use on the response.
        ///   If this is not provided, the decoder will default to the NetworkManager's default decoder.
        /// - Returns: A publisher that publishes a response matching the `responseType`.
        @available(iOS 13, *)
        public func getRequestPublisher<Response: NetworkDecodedResponse>(
                        baseURLKey: String,
                        additionalPathComponents: String? = nil,
                        queryItems: [URLQueryItem]? = nil,
                        cachePolicy: Foundation.URLRequest.CachePolicy? = nil,
                        timeoutInterval: Foundation.TimeInterval? = nil,
                        otherValidStatusCodes: [Any]? = nil,
                        retryBehaviour: RetryInfo = RetryInfo(),
                        headers: [String: String]? = nil,
                        bodyData: Data? = nil,
                        responseType: Response,
                        customDecoder: JSONDecoder? = nil) -> AnyPublisher<Response, Error> {

            guard let baseURLs = baseURLs, let baseURL = baseURLs[baseURLKey] else {
                clearCoreSDK.ccLog("baseURLKey not found in baseURL dictionary")
                assert(false)
                return Result { Response.empty }.publisher.eraseToAnyPublisher()
            }

            let fullURL = URLComponents(baseURL,
                                        additionalPathComponents: additionalPathComponents,
                                        queryItems: queryItems)
            let request = URLRequest(url: fullURL.apiURL,
                            cachePolicy: cachePolicy ?? session.ccConfiguration.requestCachePolicy,
                            timeoutInterval: timeoutInterval ?? session.ccConfiguration.timeoutIntervalForRequest,
                            method: .get,
                            headers: headers,
                            bodyData: bodyData)

            return getRequestPublisher(urlRequest: request,
                        otherValidStatusCodes: otherValidStatusCodes,
                        retryBehaviour: retryBehaviour,
                        responseType: responseType,
                        customDecoder: customDecoder)
        }

        private func validateResponse(_ response: URLResponse, otherValidStatusCodes: [Any]?) throws {
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkSessionError.invalidReponse(response)
            }
            var statusCodes = [200...299] as [Any]
            if let additionalCodes = otherValidStatusCodes {
                statusCodes.append(contentsOf: additionalCodes)
            }

            guard statusCodes.contains(code: httpResponse.statusCode) else {
                throw NetworkSessionError.invalidStatus(httpResponse)
            }
        }
    }
}

/// A protocol to be adopted by any object that coordinates a group of related, network data
/// transfer tasks or emulation thereof. The principle examples of this are `URLSession`
/// and `TestNetworkSession`, with the latter being used for unit testing.
public protocol NetworkSession {

    /// The type of values published by this publisher.
    @available(iOS 13, *)
    typealias DataTaskOutput = URLSession.DataTaskPublisher.Output

    /// A configuration object that defines behavior and policies for the network session.
    var ccConfiguration: URLSessionConfiguration { get }

    /// A method that publishes data corresponding to a URL request.
    /// - Parameter request: The URLRequest from which the data is to be retrieved..
    /// - Returns: A publisher that publishes the data when the request response is received.
    @available(iOS 13, *)
    func ccDataTaskPublisher(for request: URLRequest) -> AnyPublisher<DataTaskOutput, URLError>
}

extension ClearCoreSDK.NetworkManager {
    /// An enum for NetworkManager success/failure message logging.
    public enum LogMessage {
        case success
        case failure(Error)

        func messageString() -> String {
            switch self {
            case .success:
                return "Request publisher completed successfully"
            case .failure(let error):
                return "Request publisher completed with error: \(error.localizedDescription)"
            }
        }
    }

    /// NetworkManager's ``LogMessage`` console logging method.
    /// - Parameter message: The message to present in the console.
    public func cclog(message: LogMessage) {
        clearCoreSDK.ccLog(message.messageString())
    }
}

/// Any request publisher that is going to publish decoded (parsed) results from a request
/// will need to have the decoded results struct adopt this protocol.
public protocol NetworkDecodedResponse: Codable {
    /// An empty version of the response struct for publishing purposes.
    static var empty: Self { get }
}

private extension HTTPURLResponse {
    var allHeaderFieldsStrings: [String: String] {
        Dictionary(uniqueKeysWithValues:
            allHeaderFields
                .compactMap { (key, value) in
                    (key as? String).flatMap { key in (value as? String).flatMap { (key, $0 ) } }
                }
        )
    }
}

private extension Array where Element == Any {
    func contains(code: Int) -> Bool {
        return self.contains(where: { (arrayItem) -> Bool in
                if let intRange = arrayItem as? ClosedRange<Int>, intRange.contains(code) {
                    return true
                }
                if let intCode = arrayItem as? Int, code == intCode {
                    return true
                }
                return false
            })
    }
}
