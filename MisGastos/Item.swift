//
//  Item.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 1/26/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
