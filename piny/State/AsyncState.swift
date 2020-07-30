//
//  AsyncState.swift
//  piny
//
//  Created by John Grishin on 30/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

class AsyncState: ObservableObject {
  @Published var task: URLSessionDataTask?

  var isLoading: Bool {
    return task?.isLoading == true
  }
}
