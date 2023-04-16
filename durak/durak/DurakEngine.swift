//
//  DurakEngine.swift
//  durak
//
//  Created by Кирилл Иванников on 26.03.2023.
//

import Foundation

enum Player {
    case none
    case first
    case second
}

class DurakEngine: ObservableObject {
    @Published var deck: [Card] = []
    @Published var firstPlayerCards: [Card] = []
    @Published var secondPlayerCards: [Card] = []
    @Published var trump: Suit = .diamond
    
    @Published var priorityPlayer: Player = .none
    
    @Published var field: [(Card, Card?)] = []
    
    @Published var winPlayer: Player? = nil
    
    func makeDeck() {
        var deck: [Card] = []
        
        Denomination.allCases.forEach { denomination in
            Suit.allCases.forEach { suit in
                let card = Card(denomination, of: suit)
                deck.append(card)
            }
        }
        
        deck.shuffle()
        
        self.deck = deck
        trump = deck.last!.suit
    }
    
    func dealCards() {
        for _ in 0 ..< 6 {
            firstPlayerCards.append(deck.first!)
            deck.removeFirst()
            secondPlayerCards.append(deck.first!)
            deck.removeFirst()
        }
        
        let firstPlayerTrumpCards = firstPlayerCards.filter({ $0.suit == trump })
        let secondPlayerTrumpCards = secondPlayerCards.filter({ $0.suit == trump })
        
        if firstPlayerTrumpCards.isEmpty && secondPlayerTrumpCards.isEmpty {
            let firstPlayerMax = firstPlayerCards.max(by: { $0.denomination.rawValue > $1.denomination.rawValue })
            let secondPlayerMax = secondPlayerCards.max(by: { $0.denomination.rawValue > $1.denomination.rawValue })
            
            if firstPlayerMax!.denomination.rawValue > secondPlayerMax!.denomination.rawValue {
                priorityPlayer = .first
            } else if firstPlayerMax!.denomination.rawValue < secondPlayerMax!.denomination.rawValue {
                priorityPlayer = .second
            } else {
                priorityPlayer = Int.random(in: 0...1) == 1 ? .second : .first
            }
        } else if secondPlayerTrumpCards.isEmpty {
            priorityPlayer = .first
        } else if firstPlayerTrumpCards.isEmpty {
            priorityPlayer = .second
        } else {
            let firstPlayerMin = firstPlayerTrumpCards.min(by: { $0.denomination.rawValue < $1.denomination.rawValue })
            let secondPlayerMin = secondPlayerTrumpCards.min(by: { $0.denomination.rawValue < $1.denomination.rawValue })
            
            if firstPlayerMin!.denomination.rawValue < secondPlayerMin!.denomination.rawValue {
                priorityPlayer = .first
            } else {
                priorityPlayer = .second
            }
        }
    }
    
    func put(_ card: Card, player: Player, fieldCardIndex: Int = -1) -> Bool {
        if player == priorityPlayer {
            if field.count < 6 && (field.isEmpty || (field.map({ $0.0.denomination }) + field.map({ $0.1?.denomination })).contains(card.denomination)) {
                field.append((card, nil))
                
                if player == .first {
                    firstPlayerCards.removeAll(where: { $0 == card })
                } else {
                    secondPlayerCards.removeAll(where: { $0 == card })
                }
                
                return true
            }
            
            return false
        } else {
            if fieldCardIndex == -1 {
                return false
            }
            
            let place = field[fieldCardIndex]
            if place.1 == nil && (place.0.suit == card.suit && place.0.denomination.rawValue < card.denomination.rawValue || card.suit == trump && place.0.suit != trump) {
                field[fieldCardIndex].1 = card
                
                if player == .first {
                    firstPlayerCards.removeAll(where: { $0 == card })
                } else {
                    secondPlayerCards.removeAll(where: { $0 == card })
                }
                
                return true
            }
            
            return false
        }
    }
    
    func done() {
        if field.first(where: { $0.1 == nil }) != nil {
            if priorityPlayer == .first {
                secondPlayerCards.append(contentsOf: field.map({ $0.0 }))
                secondPlayerCards.append(contentsOf: field.compactMap({ $0.1 }))
                
                let needToTake = max(6 - firstPlayerCards.count, 0)
                if deck.count <= needToTake {
                    firstPlayerCards.append(contentsOf: deck)
                    deck = []
                } else {
                    firstPlayerCards.append(contentsOf: deck[0..<needToTake])
                    deck.removeFirst(needToTake)
                }
            } else {
                firstPlayerCards.append(contentsOf: field.map({ $0.0 }))
                firstPlayerCards.append(contentsOf: field.compactMap({ $0.1 }))
                
                let needToTake = max(6 - secondPlayerCards.count, 0)
                if deck.count <= needToTake {
                    secondPlayerCards.append(contentsOf: deck)
                    deck = []
                } else {
                    secondPlayerCards.append(contentsOf: deck[0..<needToTake])
                    deck.removeFirst(needToTake)
                }
            }
        } else {
            if priorityPlayer == .first {
                let firstNeedToTake = max(6 - firstPlayerCards.count, 0)
                if deck.count <= firstNeedToTake {
                    firstPlayerCards.append(contentsOf: deck)
                    deck = []
                } else {
                    firstPlayerCards.append(contentsOf: deck[0..<firstNeedToTake])
                    deck.removeFirst(firstNeedToTake)
                }
                
                let secondNeedToTake = max(6 - secondPlayerCards.count, 0)
                if deck.count <= secondNeedToTake {
                    secondPlayerCards.append(contentsOf: deck)
                    deck = []
                } else {
                    secondPlayerCards.append(contentsOf: deck[0..<secondNeedToTake])
                    deck.removeFirst(secondNeedToTake)
                }
            } else {
                let secondNeedToTake = max(6 - secondPlayerCards.count, 0)
                if deck.count <= secondNeedToTake {
                    secondPlayerCards.append(contentsOf: deck)
                    deck = []
                } else {
                    secondPlayerCards.append(contentsOf: deck[0..<secondNeedToTake])
                    deck.removeFirst(secondNeedToTake)
                }
                
                let firstNeedToTake = max(6 - firstPlayerCards.count, 0)
                if deck.count <= firstNeedToTake {
                    firstPlayerCards.append(contentsOf: deck)
                    deck = []
                } else {
                    firstPlayerCards.append(contentsOf: deck[0..<firstNeedToTake])
                    deck.removeFirst(firstNeedToTake)
                }
            }
            
            priorityPlayer = priorityPlayer == .first ? .second : .first
        }
        
        field = []
        checkWinner()
    }
    
    func checkWinner() {
        if deck.isEmpty {
            if firstPlayerCards.isEmpty && !secondPlayerCards.isEmpty {
                winPlayer = .first
            }
            
            if !firstPlayerCards.isEmpty && secondPlayerCards.isEmpty {
                winPlayer = .second
            }
            
            if firstPlayerCards.isEmpty && secondPlayerCards.isEmpty {
                winPlayer = Player.none
            }
        }
    }
}
