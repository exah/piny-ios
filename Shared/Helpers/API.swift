//
//  api.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import PromiseKit

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
    _ type: T.Type,
    method: String,
    path: String,
    data: Decodable? = nil,
    onTask: TaskHandler? = nil
  ) -> Promise<T> {
    return Promise { seal in
      var request = URLRequest(url: URL(string: baseURL + path)!)
      request.httpMethod = method

      if let data = data {
        do {
          let json = try JSONSerialization.data(withJSONObject: data)

          request.httpBody = json
          request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        } catch {
          seal.reject(API.Error.serializationFailed(data: data, underlyingError: error))
          return
        }
      }

      if let token = token {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }

      let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
          seal.reject(API.Error.requestFailed(path: path, underlyingError: error))
          return
        }

        if let response = response {
          if response.isOK() {
            do {
              let json = try JSON().decode(T.self, from: data!)

              DispatchQueue.main.async {
                seal.fulfill(json)
              }
            } catch {
              DispatchQueue.main.async {
                seal.reject(API.Error.parsingFailed(data: data, underlyingError: error))
              }
            }
          } else {
            let message = try? JSONDecoder().decode(API.Message.self, from: data!)

            DispatchQueue.main.async {
              seal.reject(API.Error.notOK(path: path, statusCode: response.getStatusCode(), message: message))
            }
          }
        }
      }

      task.resume()
      onTask?(task)
    }
  }

  func get<T: Decodable>(
    _ type: T.Type,
    path: String,
    onTask: TaskHandler? = nil
  ) -> Promise<T> {
    return fetch(
      type,
      method: "GET",
      path: path,
      onTask: onTask
    )
  }

  func post<T: Decodable>(
    _ type: T.Type,
    path: String,
    data: Decodable,
    onTask: TaskHandler? = nil
  ) -> Promise<T> {
    return fetch(
      type,
      method: "POST",
      path: path,
      data: data,
      onTask: onTask
    )
  }

  typealias TaskHandler = (_ task: URLSessionDataTask) -> Void

  enum Error: Swift.Error {
    case serializationFailed(data: Any?, underlyingError: Swift.Error)
    case parsingFailed(data: Any?, underlyingError: Swift.Error)
    case requestFailed(path: String, underlyingError: Swift.Error)
    case notOK(path: String, statusCode: Int?, message: API.Message?)
  }

  struct Message: Decodable, CustomStringConvertible {
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
