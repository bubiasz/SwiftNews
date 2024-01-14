//
//  APIManager.swift
//  SwiftNews
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    private enum APIError: Error {
        case invalidInput
        case invalidEndpoint
        case invalidResponse
        case invalidResponseData
    }
    
    private init() {}
    
    public func getData<T: Decodable>(from endpoint: String) async throws -> T {
        guard let url = URL(string: "http://172.20.10.3:8080/api/\(endpoint)") else {
            throw APIError.invalidEndpoint
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(T.self, from: data) else {
            throw APIError.invalidResponseData
        }
        
        return decodedData
    }
    
    public func postData<T: Encodable, U: Decodable>(data: T, to endpoint: String) async throws -> U {
        let encoder = JSONEncoder()
        guard let requestBody = try? encoder.encode(data) else {
            throw APIError.invalidInput
        }
        
        guard let url = URL(string: "http://172.20.10.3:8080/api/\(endpoint)") else {
            throw APIError.invalidEndpoint
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(U.self, from: data) else {
            throw APIError.invalidResponseData
        }
        
        return decodedData
    }
}
