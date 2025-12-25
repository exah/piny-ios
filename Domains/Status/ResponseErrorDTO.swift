//
//  ResponseErrorDTO.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

struct ResponseErrorDTO<Meta: Codable>: Codable {
  let id: String
  let code: ErrorCode
  let message: String
  let meta: Meta?
  let requestId: String?
}
