//
//  Card.swift
//  durak
//
//  Created by Кирилл Иванников on 19.03.2023.
//

import Foundation

struct Card: Equatable {
    let denomination: Denomination
    let suit: Suit
    
    init(_ denomination: Denomination, of suit: Suit) {
        self.denomination = denomination
        self.suit = suit
    }
}

extension Card {
    var rawValue: String {
        return denomination.text + suit.rawValue
    }
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
