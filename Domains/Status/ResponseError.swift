//
//  PinyError.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

enum ResponseError: Error {
  case badRequest(String? = nil, meta: Data? = nil)
  case unauthorized(String? = nil, meta: Data? = nil)
  case forbidden(String? = nil, meta: Data? = nil)
  case notFound(String? = nil, meta: Data? = nil)
  case notAcceptable(String? = nil, meta: Data? = nil)
  case conflict(String? = nil, meta: Data? = nil)
  case internalServerError(String? = nil, meta: Data? = nil)
  case parsingError(String? = nil, meta: ValidationMetaDTO? = nil)
  case sessionAlreadyRefreshed(String? = nil, meta: Data? = nil)
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

  var meta: Any? {
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
      case .unknown, .networkError, .decodingError: return nil
    }
  }

  init(from error: ResponseErrorDTO<Data>) {
    self =
      switch error.code {
        case .parsingError:
          .parsingError(
            error.message,
            meta: error.meta.flatMap { try? JSONDecoder().decode(ValidationMetaDTO.self, from: $0) }
          )
        case .badRequest:
          .badRequest(error.message, meta: error.meta)
        case .unauthorized:
          .unauthorized(error.message, meta: error.meta)
        case .forbidden:
          .forbidden(error.message, meta: error.meta)
        case .notFound:
          .notFound(error.message, meta: error.meta)
        case .notAcceptable:
          .notAcceptable(error.message, meta: error.meta)
        case .conflict:
          .conflict(error.message, meta: error.meta)
        case .internalServerError:
          .internalServerError(error.message, meta: error.meta)
        case .sessionAlreadyRefreshed:
          .sessionAlreadyRefreshed(error.message, meta: error.meta)
        case .none:
          .unknown(error.message)
      }
  }

  init(from response: HTTPURLResponse) {
    self =
      switch response.statusCode {
        case 400:
          .badRequest()
        case 401:
          .unauthorized()
        case 403:
          .forbidden()
        case 404:
          .notFound()
        case 406:
          .notAcceptable()
        case 409:
          .conflict()
        case 500:
          .internalServerError()
        default:
          .unknown("HTTP \(response.statusCode)")
      }
  }

  init(
    from data: Data,
    response: HTTPURLResponse
  ) {
    if let error = try? JSONDecoder().decode(ResponseErrorDTO<Data>.self, from: data) {
      self.init(from: error)
    } else {
      self.init(from: response)
    }
  }
}
