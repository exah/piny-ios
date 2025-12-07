//
//  api.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

private struct Empty: Encodable {}

private extension URLResponse {
  func getStatusCode() -> Int? {
    if let response = self as? HTTPURLResponse {
      return response.statusCode
    }

    return nil
  }

  func isOK() -> Bool {
    return (200...299).contains(getStatusCode() ?? 0)
  }
}

struct API {
  var baseURL: String
  var token: String? = nil

  private let session = URLSession(configuration: .default)

  @MainActor
  func fetch<Output: Decodable, Input: Encodable>(
    _ type: Output.Type,
    method: String,
    path: String,
    json: Input
  ) async throws -> Output {
    var request = URLRequest(url: URL(string: baseURL + path)!)
    request.httpMethod = method

    if !(json is Empty) {
      do {
        let json = try JSON().encode(json)
        request.httpBody = json
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      } catch {
        throw API.Error.serializationFailed(data: json, underlyingError: error)
      }
    }

    if let token = token {
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    let (responseData, response): (Data, URLResponse)
    do {
      (responseData, response) = try await session.data(for: request)
    } catch {
      throw API.Error.requestFailed(path: path, underlyingError: error)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw API.Error.requestFailed(path: path, underlyingError: NSError(domain: "API", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
    }

    if httpResponse.isOK() {
      do {
        return try JSON().decode(Output.self, from: responseData)
      } catch {
        throw API.Error.parsingFailed(data: responseData, underlyingError: error)
      }
    } else {
      let message = try? JSONDecoder().decode(API.Message.self, from: responseData)
      throw API.Error.notOK(path: path, statusCode: httpResponse.statusCode, method: method, message: message)
    }
  }

  @MainActor
  func get<Output: Decodable>(
    _ type: Output.Type,
    path: String
  ) async throws -> Output {
    try await fetch(
      type,
      method: "GET",
      path: path,
      json: Empty()
    )
  }

  @MainActor
  func post<Output: Decodable, Input: Encodable>(
    _ type: Output.Type,
    path: String,
    json: Input
  ) async throws -> Output {
    try await fetch(
      type,
      method: "POST",
      path: path,
      json: json
    )
  }

  @MainActor
  func patch<Output: Decodable, Input: Encodable>(
    _ type: Output.Type,
    path: String,
    json: Input
  ) async throws -> Output {
    try await fetch(
      type,
      method: "PATCH",
      path: path,
      json: json
    )
  }

  @MainActor
  func delete<Output: Decodable>(
    _ type: Output.Type,
    path: String
  ) async throws -> Output {
    try await fetch(
      type,
      method: "DELETE",
      path: path,
      json: Empty()
    )
  }

  enum Error: Swift.Error, CustomStringConvertible {
    case serializationFailed(data: Any?, underlyingError: Swift.Error)
    case parsingFailed(data: Any?, underlyingError: Swift.Error)
    case requestFailed(path: String, underlyingError: Swift.Error)
    case notOK(path: String, statusCode: Int?, method: String, message: API.Message?)

    var description: String {
      switch self {
        case .serializationFailed(let data, let underlyingError):
          return "API.Error: Can't serialize Input JSON, data: \(String(describing: data))\n\(String(describing: underlyingError))"
        case .requestFailed(let path, let underlyingError):
          return "API.Error: Can't fetch '\(path)'\n\(String(describing: underlyingError))"
        case .parsingFailed(let data, let underlyingError):
          return "API.Error: Can't parse result JSON, data: \(String(describing: data))\n\(String(describing: underlyingError))"
        case .notOK(let path, let statusCode, let method, let message):
          return "API.Error: Request \(path), method: '\(method)' status: '\(statusCode ?? 0)'\n\(String(describing: message))"
      }
    }
  }

  struct Message: Decodable, CustomStringConvertible {
    let message: String
    var description: String {
      return message
    }
  }
}
