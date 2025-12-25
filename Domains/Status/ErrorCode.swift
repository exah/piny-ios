//
//  ErrorCode.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
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

