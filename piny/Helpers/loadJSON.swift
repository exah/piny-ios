//
//  loadJSON.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

func loadJSON<T: Decodable>(_ filename: String) -> T {
  let data: Data
  
  guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
    fatalError("Couldn't find \(filename) in main bundle.")
  }
  
  do {
    data = try Data(contentsOf: file)
  } catch {
    fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
  }
  
  do {
    return try JSONDecoder().decode(T.self, from: data)
  } catch {
    fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
  }
}