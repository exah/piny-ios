//
//  ValidationMetaDTO.swift
//  piny
//
//  Created by J. Grishin on 25/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Foundation

struct ValidationIssue: Codable {
  let message: String
  let path: [ValidationIssuePathItem]?
}

struct ValidationIssuePathItem: Codable {
  let key: String
}

struct ValidationMetaDTO: Codable {
  let issues: [ValidationIssue]
}
