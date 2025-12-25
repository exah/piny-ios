//
//  PinyError.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

enum ResponseError: Error {
  case badRequest(String? = nil, meta: Any? = nil)
  case unauthorized(String? = nil, meta: Any? = nil)
  case forbidden(String? = nil, meta: Any? = nil)
  case notFound(String? = nil, meta: Any? = nil)
  case notAcceptable(String? = nil, meta: Any? = nil)
  case conflict(String? = nil, meta: Any? = nil)
  case internalServerError(String? = nil, meta: Any? = nil)
  case parsingError(String? = nil, meta: ValidationMetaDTO? = nil)
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

  init(
    from data: Data,
    response: HTTPURLResponse
  ) {
    if let error = try? JSONDecoder().decode(ResponseErrorDTO<EmptyDTO>.self, from: data) {
      switch error.code {
        case .parsingError:
          let data = try? JSONDecoder().decode(ResponseErrorDTO<ValidationMetaDTO>.self, from: data)
          self = .parsingError(error.message, meta: data?.meta)
        case .badRequest:
          self = .badRequest(error.message, meta: nil)
        case .unauthorized:
          self = .unauthorized(error.message, meta: nil)
        case .forbidden:
          self = .forbidden(error.message, meta: nil)
        case .notFound:
          self = .notFound(error.message, meta: nil)
        case .notAcceptable:
          self = .notAcceptable(error.message, meta: nil)
        case .conflict:
          self = .conflict(error.message, meta: nil)
        case .internalServerError:
          self = .internalServerError(error.message, meta: nil)
        case .sessionAlreadyRefreshed:
          self = .sessionAlreadyRefreshed(error.message, meta: nil)
        case .none:
          self = .unknown(error.message)
      }
    } else {
      switch response.statusCode {
        case 400:
          self = .badRequest()
        case 401:
          self = .unauthorized()
        case 403:
          self = .forbidden()
        case 404:
          self = .notFound()
        case 406:
          self = .notAcceptable()
        case 409:
          self = .conflict()
        case 500:
          self = .internalServerError()
        default:
          self = .unknown("HTTP \(response.statusCode)")
      }
    }
  }
}
