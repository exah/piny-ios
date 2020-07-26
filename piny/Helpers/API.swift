//
//  api.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

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

  func fetch<T: Decodable>(
    method: String,
    path: String,
    data: Decodable? = nil,
    onCompletion: @escaping API.Completion<T>
  ) -> URLSessionDataTask? {
    var request = URLRequest(url: URL(string: baseURL + path)!)
    request.httpMethod = method

    if let data = data {
      do {
        let json = try JSONSerialization.data(withJSONObject: data)

        request.httpBody = json
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      } catch {
        onCompletion(.failure(API.Error.serializationFailed(data: data, underlyingError: error)))
        return nil
      }
    }
    
    if let token = token {
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    let task = session.dataTask(with: request) { data, response, error in
      if let error = error {
        onCompletion(.failure(API.Error.requestFailed(path: path, underlyingError: error)))
        return
      }

      if let response = response {
        if response.isOK() {
          do {
            let json = try JSONDecoder().decode(T.self, from: data!)

            DispatchQueue.main.async {
              onCompletion(.success(json))
            }
          } catch {
            DispatchQueue.main.async {
              onCompletion(.failure(API.Error.parsingFailed(data: data, underlyingError: error)))
            }
          }
        } else {
          let message = try? JSONDecoder().decode(API.ResultMessage.self, from: data!)

          DispatchQueue.main.async {
            onCompletion(.failure(API.Error.notOK(path: path, statusCode: response.getStatusCode(), message: message)))
          }
        }
      }
    }

    task.resume()
    return task
  }

  func get<T: Decodable>(
    path: String,
    onCompletion: @escaping API.Completion<T>
  ) -> URLSessionDataTask? {
    return fetch(
      method: "GET",
      path: path,
      onCompletion: onCompletion
    )
  }

  func post<T: Decodable>(
    path: String,
    data: Decodable,
    onCompletion: @escaping API.Completion<T>
  ) -> URLSessionDataTask? {
    return fetch(
      method: "POST",
      path: path,
      data: data,
      onCompletion: onCompletion
    )
  }

  typealias Result<T> = Swift.Result<T, Error>
  typealias Completion<T> = (_ result: API.Result<T>) -> Void

  enum Error: Swift.Error {
    case serializationFailed(data: Any?, underlyingError: Swift.Error)
    case parsingFailed(data: Any?, underlyingError: Swift.Error)
    case requestFailed(path: String, underlyingError: Swift.Error)
    case notOK(path: String, statusCode: Int?, message: API.ResultMessage?)
  }

  struct ResultMessage: Decodable, CustomStringConvertible {
    let message: String
    var description: String {
      return message
    }
  }
}

extension API.Error: CustomStringConvertible {
  var description: String {
    switch self {
      case .serializationFailed(let data, let underlyingError):
        return "API.Error: Can't serialize body JSON, data: \(String(describing: data))\n\(String(describing: underlyingError))"
      case .requestFailed(let path, let underlyingError):
        return "API.Error: Can't fetch '\(path)'\n\(String(describing: underlyingError))"
      case .parsingFailed(let data, let underlyingError):
        return "API.Error: Can't parse result JSON, data: \(String(describing: data))\n\(String(describing: underlyingError))"
      case .notOK(let path, let statusCode, let message):
        return "API.Error: Request \(path), status: '\(statusCode ?? 0)'\n\(String(describing: message))"
    }
  }
}
