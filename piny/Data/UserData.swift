//
//  UserData.swift
//  piny
//
//  Created by John Grishin on 14/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import Combine

final class UserData: ObservableObject {
  @Published var pins: [Pin] = loadJSON("pins.json")
}
