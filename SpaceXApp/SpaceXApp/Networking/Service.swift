//
//  Service.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-02-24.
//

import Foundation
import Combine

/// Represents the available endpoints for the SpaceX API.
enum Endpoint: String {
    case launches = "launches"
    case rockets = "rockets"
    case roadster = "roadster"
}

/// Represents the possible errors that can occur in the service.
enum ServiceError: Error {
    case networkError
    case invalidURL
    case invalidResponse

    init(error: Error) {
        self = .networkError
        print(error)
    }
}

/// A service class responsible for making network requests to the SpaceX API.
final class Service {
    private let baseURL: String = "https://api.spacexdata.com/v4/"
    
    // Lazily initialize the JSONDecoder with a custom date decoding strategy.
    private lazy var decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let dateFormatter = DateFormatter()
            if dateString.range(of: #":\d{2}[+-]"#, options: .regularExpression) != nil {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            } else {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
            }
            guard let date = dateFormatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date")
            }
            return date
        }
        return jsonDecoder
    }()
    
    /// The shared instance of the Service class.
    public static let standard: Service = Service()
    
    /// Makes a GET request to the specified endpoint and decodes the response into the specified type.
    /// - Parameters:
    ///   - path: The endpoint to request.
    ///   - responseType: The type to decode the response into.
    /// - Returns: A publisher that emits the decoded response or an error.
    func get<T: Decodable>(path: Endpoint, responseType: T.Type) -> AnyPublisher<T, ServiceError> {
        guard let url = URL(string: self.baseURL + path.rawValue) else {
            return Fail(error: ServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { ServiceError(error: $0) }
            .flatMap { data, response -> AnyPublisher<T, ServiceError> in
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    return Fail(error: ServiceError.invalidResponse).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: T.self, decoder: self.decoder)
                    .mapError { _ in ServiceError.invalidResponse }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

