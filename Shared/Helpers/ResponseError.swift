//
//  PinyError.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

enum ErrorCode: Int, Codable {
  case none = 0

  case badRequest = 400
  case unauthorized = 401
  case forbidden = 403
  case notFound = 404
  case notAcceptable = 406
  case conflict = 409
  case internalServerError = 500

  case parsingError = 1000
  case sessionAlreadyRefreshed = 1001

  var message: String {
    switch self {
      case .badRequest:
        return "👎 Bad request"
      case .unauthorized:
        return "🙅‍♂️ Unauthorized"
      case .forbidden:
        return "✋ Denied"
      case .notFound:
        return "🤷‍♂️ Not found"
      case .notAcceptable:
        return "👀 What is it?"
      case .conflict:
        return "🙅‍♂️ Already exists"
      case .internalServerError:
        return "😭 Something went wrong"
      case .parsingError:
        return "🤦‍♂️ Parsing error"
      case .sessionAlreadyRefreshed:
        return "🙅‍♂️ Already refreshed"
      case .none:
        return "❓ Unknown"
    }
  }
}

struct ValidationIssue: Codable {
  let message: String
  let path: [ValidationIssuePathItem]?
}

struct ValidationIssuePathItem: Codable {
  let key: String
}

struct ValidationMeta: Codable {
  let issues: [ValidationIssue]
}

struct ResponseErrorDTO<Meta: Codable>: Codable {
  let id: String
  let code: ErrorCode
  let message: String
  let meta: Meta?
  let requestId: String?
}

struct PinyMessageResponse: Codable {
  let message: String
}

enum ResponseError: Error {
  case badRequest(String? = nil, meta: Any? = nil)
  case unauthorized(String? = nil, meta: Any? = nil)
  case forbidden(String? = nil, meta: Any? = nil)
  case notFound(String? = nil, meta: Any? = nil)
  case notAcceptable(String? = nil, meta: Any? = nil)
  case conflict(String? = nil, meta: Any? = nil)
  case internalServerError(String? = nil, meta: Any? = nil)
  case parsingError(String? = nil, meta: ValidationMeta? = nil)
  case sessionAlreadyRefreshed(String? = nil, meta: Any? = nil)
  case networkError(Error)
  case decodingError(Error)
  case unknown(String? = nil)

  var errorDescription: String? {
    switch self {
      case .badRequest(let message, _):
        return message ?? ErrorCode.badRequest.message
      case .unauthorized(let message, _):
        return message ?? ErrorCode.unauthorized.message
      case .forbidden(let message, _):
        return message ?? ErrorCode.forbidden.message
      case .notFound(let message, _):
        return message ?? ErrorCode.notFound.message
      case .notAcceptable(let message, _):
        return message ?? ErrorCode.notAcceptable.message
      case .conflict(let message, _):
        return message ?? ErrorCode.conflict.message
      case .internalServerError(let message, _):
        return message ?? ErrorCode.internalServerError.message
      case .parsingError(let message, _):
        return message ?? ErrorCode.parsingError.message
      case .sessionAlreadyRefreshed(let message, _):
        return message ?? ErrorCode.sessionAlreadyRefreshed.message
      case .networkError(let error):
        return "Network error: \(error.localizedDescription)"
      case .decodingError(let error):
        return "Decoding error: \(error.localizedDescription)"
      case .unknown(let message):
        return message ?? "Unknown error occurred"
    }
  }

  var code: ErrorCode {
    switch self {
      case .badRequest: return .badRequest
      case .unauthorized: return .unauthorized
      case .forbidden: return .forbidden
      case .notFound: return .notFound
      case .notAcceptable: return .notAcceptable
      case .conflict: return .conflict
      case .internalServerError: return .internalServerError
      case .parsingError: return .parsingError
      case .sessionAlreadyRefreshed: return .sessionAlreadyRefreshed
      default: return .none
    }
  }

  var metadata: Any? {
    switch self {
      case .badRequest(_, let meta): return meta
      case .unauthorized(_, let meta): return meta
      case .forbidden(_, let meta): return meta
      case .notFound(_, let meta): return meta
      case .notAcceptable(_, let meta): return meta
      case .conflict(_, let meta): return meta
      case .internalServerError(_, let meta): return meta
      case .parsingError(_, let meta): return meta
      case .sessionAlreadyRefreshed(_, let meta): return meta
      default: return nil
    }
  }

  static func get(
    data: Data?,
    response: HTTPURLResponse?
  ) -> ResponseError {
    guard let httpResponse = response else {
      return .unknown("Invalid response")
    }

    guard
      let data = data,
      let error = try? JSONDecoder()
        .decode(
          ResponseErrorDTO<Empty>.self,
          from: data
        )
    else {
      switch httpResponse.statusCode {
        case 400:
          return .badRequest()
        case 401:
          return .unauthorized()
        case 403:
          return .forbidden()
        case 404:
          return .notFound()
        case 406:
          return .notAcceptable()
        case 409:
          return .conflict()
        case 500:
          return .internalServerError()
        default:
          return .unknown("HTTP \(httpResponse.statusCode)")
      }
    }

    switch error.code {
      case .parsingError:
        let data = try? JSONDecoder()
          .decode(
            ResponseErrorDTO<ValidationMeta>.self,
            from: data
          )

        return .parsingError(error.message, meta: data?.meta)
      case .badRequest:
        return .badRequest(error.message, meta: nil)
      case .unauthorized:
        return .unauthorized(error.message, meta: nil)
      case .forbidden:
        return .forbidden(error.message, meta: nil)
      case .notFound:
        return .notFound(error.message, meta: nil)
      case .notAcceptable:
        return .notAcceptable(error.message, meta: nil)
      case .conflict:
        return .conflict(error.message, meta: nil)
      case .internalServerError:
        return .internalServerError(error.message, meta: nil)
      case .sessionAlreadyRefreshed:
        return .sessionAlreadyRefreshed(error.message, meta: nil)
      case .none:
        return .unknown(error.message)
    }
  }
}
