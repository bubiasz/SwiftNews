//
//  SwiftNews
//

import Foundation


class APIManager {
    static let shared = APIManager()
    
    private enum APIError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
        case invalidInput
    }

    
    private init() {}
    
    public func getData<T: Decodable>(from endpoint: String) async throws -> T {
        guard let url = URL(string: "http://127.0.0.1:8000/api/\(endpoint)") else {
            throw APIError.invalidInput
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            throw APIError.invalidData
        }
    }
    
    public func postData<T: Encodable, U: Decodable>(data: T, to endpoint: String) async throws -> U {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(data) else {
            throw APIError.invalidData
        }
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(U.self, from: data) else {
            throw APIError.invalidData
        }
        
        return decodedData
    }
}
