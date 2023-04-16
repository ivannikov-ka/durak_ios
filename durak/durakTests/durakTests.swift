//
//  durakTests.swift
//  durakTests
//
//  Created by Кирилл Иванников on 26.03.2023.
//

import XCTest

final class durakTests: XCTestCase {
    func testCreateDurakEngine() {
        let engine = DurakEngine()
        XCTAssertNotNil(engine)
    }
    
    func testMakeDeck() {
        let engine = DurakEngine()
        engine.makeDeck()
        
        XCTAssertEqual(engine.deck.count, 36)
        
        Denomination.allCases.forEach { denomination in
            XCTAssertEqual(engine.deck.filter({ $0.denomination == denomination }).count, 4)
        }
        
        Suit.allCases.forEach { suit in
            XCTAssertEqual(engine.deck.filter({ $0.suit == suit }).count, 9)
        }
    }
    
    func testDealCards() {
        let engine = DurakEngine()
        engine.makeDeck()
        engine.dealCards()
        
        XCTAssertEqual(engine.trump, engine.deck.last!.suit)
        
        XCTAssertEqual(engine.firstPlayerCards.count, 6)
        XCTAssertEqual(engine.secondPlayerCards.count, 6)
        
        engine.firstPlayerCards.forEach { card in
            XCTAssertNil(engine.deck.first(where: { $0 == card }))
            XCTAssertNil(engine.secondPlayerCards.first(where: { $0 == card }))
        }
        
        XCTAssertEqual(engine.deck.count, 24)
    }
    
    func testPriorityPlayerAtStart() {
        let engine = DurakEngine()
        engine.makeDeck()
        
        engine.deck[35] = Card(.ace, of: .diamond)
        
        engine.deck.removeAll(where: { $0.denomination == .six && $0.suit == .diamond })
        engine.deck[0] = Card(.six, of: .diamond)
        
        engine.dealCards()
        
        XCTAssertEqual(engine.priorityPlayer, .first)
    }
    
    func testPutCardCheckField() {
        let engine = DurakEngine()
        engine.makeDeck()
        engine.dealCards()
        
        let priorityPlayer = engine.priorityPlayer
        let card = priorityPlayer == .first ? engine.firstPlayerCards.first! : engine.secondPlayerCards.first!
        _ = engine.put(card, player: priorityPlayer, fieldCardIndex: 0)
        
        XCTAssertNil(engine.firstPlayerCards.first(where: { $0 == card }))
        XCTAssertNil(engine.secondPlayerCards.first(where: { $0 == card }))
        XCTAssertEqual(engine.field.first!.0, card)
    }
    
    func testPutCardInGame() {
        let engine = DurakEngine()
        engine.trump = .diamond
        engine.priorityPlayer = .first
        
        engine.firstPlayerCards = [
            Card(.jack, of: .club),
            Card(.six, of: .spade),
            Card(.eight, of: .diamond)
        ]
        
        engine.secondPlayerCards = [
            Card(.ace, of: .spade),
            Card(.six, of: .diamond),
            Card(.queen, of: .heart)
        ]
        
        var card = engine.firstPlayerCards[2]
        var result = engine.put(card, player: .first)
        XCTAssertEqual(result, true)
        XCTAssertEqual(engine.field.first!.0, card)
        
        card = engine.secondPlayerCards[1]
        result = engine.put(card, player: .second, fieldCardIndex: 0)
        XCTAssertEqual(result, false)
        XCTAssertNil(engine.field.first!.1)
        
        card = engine.firstPlayerCards[0]
        result = engine.put(card, player: .first)
        XCTAssertEqual(result, false)
        XCTAssertEqual(engine.field.count, 1)
        
        engine.field = []
        
        card = engine.firstPlayerCards[1]
        _ = engine.put(card, player: .first)
        let card2 = engine.secondPlayerCards[1]
        result = engine.put(card2, player: .second, fieldCardIndex: 0)
        XCTAssertEqual(result, true)
        XCTAssertEqual(engine.field.first!.0, card)
        XCTAssertEqual(engine.field.first!.1, card2)
        XCTAssertNil(engine.firstPlayerCards.first(where: { $0 == card }))
        XCTAssertNil(engine.secondPlayerCards.first(where: { $0 == card2 }))
    }
    
    func testDoneSecondFool() {
        let engine = DurakEngine()
        engine.makeDeck()
        engine.trump = .diamond
        engine.priorityPlayer = .first
        
        engine.firstPlayerCards = [
            Card(.jack, of: .club),
            Card(.six, of: .spade),
            Card(.eight, of: .diamond)
        ]
        
        engine.secondPlayerCards = [
            Card(.ace, of: .spade),
            Card(.six, of: .heart),
            Card(.queen, of: .heart),
            Card(.king, of: .spade),
            Card(.seven, of: .heart),
            Card(.jack, of: .heart)
        ]
        
        let card = engine.firstPlayerCards[0]
        _ = engine.put(card, player: .first)
        engine.done()
        
        XCTAssertEqual(engine.firstPlayerCards.count, 6)
        XCTAssertEqual(engine.secondPlayerCards.count, 7)
        XCTAssertEqual(engine.priorityPlayer, .first)
    }
    
    func testDoneSecondGood() {
        let engine = DurakEngine()
        engine.makeDeck()
        engine.trump = .diamond
        engine.priorityPlayer = .first
        
        engine.firstPlayerCards = [
            Card(.jack, of: .club),
            Card(.six, of: .spade),
            Card(.eight, of: .diamond)
        ]
        
        engine.secondPlayerCards = [
            Card(.ace, of: .spade),
            Card(.six, of: .heart),
            Card(.queen, of: .heart),
            Card(.king, of: .spade),
            Card(.seven, of: .heart),
            Card(.jack, of: .heart)
        ]
        
        let card1 = engine.firstPlayerCards[1]
        _ = engine.put(card1, player: .first)
        let card2 = engine.secondPlayerCards[0]
        _ = engine.put(card2, player: .second, fieldCardIndex: 0)
        engine.done()
        
        XCTAssertEqual(engine.firstPlayerCards.count, 6)
        XCTAssertEqual(engine.secondPlayerCards.count, 6)
        XCTAssertEqual(engine.priorityPlayer, .second)
    }
    
    func testCheckFirstWin() {
        let engine = DurakEngine()
        engine.priorityPlayer = .first
        
        engine.firstPlayerCards = [
            Card(.jack, of: .club)
        ]
        
        engine.secondPlayerCards = [
            Card(.ace, of: .spade)
        ]
        
        _ = engine.put(engine.firstPlayerCards[0], player: .first)
        engine.done()
        
        XCTAssertEqual(engine.winPlayer, .first)
    }
    
    func testCheckNoneWin() {
        let engine = DurakEngine()
        engine.priorityPlayer = .first
        
        engine.firstPlayerCards = [
            Card(.jack, of: .club)
        ]
        
        engine.secondPlayerCards = [
            Card(.king, of: .club)
        ]
        
        _ = engine.put(engine.firstPlayerCards[0], player: .first)
        _ = engine.put(engine.secondPlayerCards[0], player: .second, fieldCardIndex: 0)
        engine.done()
        
        XCTAssertEqual(engine.winPlayer, Player.none)
    }
    
    func testCheckNilWin() {
        let engine = DurakEngine()
        engine.makeDeck()
        engine.dealCards()
        engine.done()
        
        XCTAssertNil(engine.winPlayer)
    }
}
