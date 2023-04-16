//
//  Suit.swift
//  durak
//
//  Created by Кирилл Иванников on 19.03.2023.
//

import Foundation
import SwiftUI

enum Suit: String, CaseIterable {
    case heart
    case diamond
    case club
    case spade
}

extension Suit {
    var image: Image {
        switch self {
        case .heart:
            return Image(systemName: "heart.fill")
        case .diamond:
            return Image(systemName: "suit.diamond.fill")
        case .club:
            return Image(systemName: "suit.club.fill")
        case .spade:
            return Image(systemName: "suit.spade.fill")
        }
    }
    
    var color: Color {
        switch self {
        case .heart, .diamond:
            return .red
        case .club, .spade:
            return .black
        }
    }
}
