//
//  api.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

struct Empty: Codable {}

extension URLResponse {
  fileprivate func getStatusCode() -> Int? {
    if let response = self as? HTTPURLResponse {
      return response.statusCode
    }

    return nil
  }

  fileprivate func isOK() -> Bool {
    return (200...299).contains(getStatusCode() ?? 0)
  }
}

struct API {
  let baseURL: String
  let sessionActor = SessionActor(modelContainer: .shared)

  private let session = URLSession(configuration: .default)

  func fetch<Output: Decodable, Input: Encodable>(
    _ type: Output.Type,
    method: String,
    path: String,
    json: Input
  ) async throws -> Output {
    let requestId = UUID()
    var request = URLRequest(url: URL(string: baseURL + path)!)

    request.httpMethod = method
    request.addValue(requestId.uuidString, forHTTPHeaderField: "X-Request-ID")

    if !(json is Empty) {
      do {
        let json = try JSON().encode(json)
        request.httpBody = json
        request.addValue(
          "application/json; charset=utf-8",
          forHTTPHeaderField: "Content-Type"
        )
      } catch {
        throw ResponseError.unknown(
          "Serialization failed: \(error.localizedDescription)"
        )
      }
    }

    if let token = try? await sessionActor.get().token {
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    let (responseData, response): (Data, URLResponse)
    do {
      (responseData, response) = try await session.data(for: request)
    } catch {
      throw ResponseError.networkError(error)
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      throw ResponseError.unknown("Invalid response")
    }

    if !httpResponse.isOK() {
      throw ResponseError.get(data: responseData, response: httpResponse)
    }

    do {
      return try JSON().decode(Output.self, from: responseData)
    } catch {
      throw ResponseError.decodingError(error)
    }
  }

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

  @discardableResult
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

  @discardableResult
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

  @discardableResult
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
}
