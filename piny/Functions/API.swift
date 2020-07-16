//
//  api.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation

typealias SuccessHandler<T> = (_ json: T) -> Void

struct API {
  let baseURL: String
  var token: String? = nil

  private let session = URLSession(configuration: .default)

  func fetch<T: Decodable>(
    method: String,
    path: String,
    data: Decodable? = nil,
    onSuccess: @escaping SuccessHandler<T>
  ) throws -> URLSessionDataTask {
    var request = URLRequest(url: URL(string: baseURL + path)!)
    request.httpMethod = method
    
    if data != nil {
      let json = try JSONSerialization.data(withJSONObject: data!)

      request.httpBody = json
      request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }
    
    if token != nil {
      request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
    }

    let task = session.dataTask(with: request) { data, response, error in
      if error != nil {
        print("Can't fetch '\(path)': \(error!)")
        return
      }
      
      print("Response: \(response!)")

      do {
        let json = try JSONDecoder().decode(T.self, from: data!)
        
        DispatchQueue.main.async {
          onSuccess(json)
        }
      } catch {
        print("Can't parse result JSON")
      }
    }
    
    task.resume()
    return task
  }
  
  func get<T: Decodable>(
    path: String,
    onSuccess: @escaping SuccessHandler<T>
  ) throws -> URLSessionDataTask {
    return try fetch(
      method: "GET",
      path: path,
      onSuccess: onSuccess
    )
  }
  
  func post<T: Decodable>(
    path: String,
    data: Decodable,
    onSuccess: @escaping SuccessHandler<T>
  ) throws -> URLSessionDataTask {
    return try fetch(
      method: "POST",
      path: path,
      data: data,
      onSuccess: onSuccess
    )
  }
}
