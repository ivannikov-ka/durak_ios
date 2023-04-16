//
//  Denomination.swift
//  durak
//
//  Created by Кирилл Иванников on 19.03.2023.
//

import Foundation
import SwiftUI

enum Denomination: Int, CaseIterable {
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    
    case jack = 12
    case queen = 13
    case king = 14
    case ace = 21
}

extension Denomination {
    var text: String {
        switch self {
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .ten:
            return "10"
        case .jack:
            return "J"
        case .queen:
            return "Q"
        case .king:
            return "K"
        case .ace:
            return "A"
        }
    }
}
