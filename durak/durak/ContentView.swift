//
//  ContentView.swift
//  durak
//
//  Created by Кирилл Иванников on 19.03.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var engine: DurakEngine
    @State var selectedFieldIndex: Int = -1
    
    @Namespace private var animation
    
    var started: Bool {
        engine.priorityPlayer != .none || !engine.deck.isEmpty
    }
    
    var body: some View {
        if !started {
            Button(action: {
                engine.makeDeck()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 2)) {
                        engine.dealCards()
                    }
                }
            }, label: {
                Text("START")
                    .font(.title)
            })
        } else {
            GeometryReader { geometry in
                let cardSize = geometry.size.height * 0.11
                
                VStack {
                    let enabled = (engine.field.map({ $0.1 }).contains(nil) ? engine.priorityPlayer == .first : engine.priorityPlayer == .second) && engine.field.count > 0
                    
                    Button(action: {
                        withAnimation {
                            engine.done()
                        }
                    }, label: {
                        Text("Готово")
                            .rotationEffect(.degrees(180))
                    })
                    .disabled(!enabled)
                    .opacity(enabled ? 1 : 0.3)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 5) {
                            ForEach(engine.secondPlayerCards, id: \.rawValue) { card in
                                CardView(card: card)
                                    .matchedGeometryEffect(id: card.rawValue, in: animation)
                                    .frame(height: cardSize)
                                    .onTapGesture {
                                        withAnimation {
                                            if engine.put(card, player: .second, fieldCardIndex: selectedFieldIndex) {
                                                selectedFieldIndex = engine.field.firstIndex(where: { $0.1 == nil }) ?? -1
                                            } else {
                                                selectedFieldIndex = -1
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    if let winPlayer = engine.winPlayer {
                        Text(winPlayer == .second ? "Вы выиграли" : "Вы проиграли")
                            .font(.title)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(180))
                    } else {
                        Text(engine.priorityPlayer == .second ? "Вы ходите" : "Ходит другой игрок")
                            .font(.title)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(180))
                    }
                    
                    Spacer()
                    
                    HStack {
                        let field = engine.field
                        VStack {
                            HStack {
                                let topIndex = min(field.count, 3)
                                if topIndex > 0 {
                                    ForEach(field[0..<topIndex].indices, id: \.self) { index in
                                        let bottomCard = field[index].0
                                        let topCard = field[index].1
                                        
                                        ZStack {
                                            CardView(card: bottomCard)
                                                .frame(height: cardSize)
                                                .opacity(selectedFieldIndex == index ? 0.6 : 1)
                                                .matchedGeometryEffect(id: bottomCard.rawValue, in: animation)
                                                .onTapGesture {
                                                    if topCard == nil {
                                                        if selectedFieldIndex == index {
                                                            selectedFieldIndex = -1
                                                        } else {
                                                            selectedFieldIndex = index
                                                        }
                                                    }
                                                }
                                            if let topCard {
                                                CardView(card: topCard)
                                                    .frame(height: cardSize)
                                                    .offset(x: cardSize * 0.1, y: cardSize * 0.5)
                                                    .matchedGeometryEffect(id: bottomCard.rawValue, in: animation)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if field.count > 3 {
                                HStack {
                                    ForEach(field[3...].indices, id: \.self) { index in
                                        let bottomCard = field[index].0
                                        let topCard = field[index].1
                                        
                                        ZStack {
                                            CardView(card: bottomCard)
                                                .frame(height: cardSize)
                                                .opacity(selectedFieldIndex == index ? 0.6 : 1)
                                                .matchedGeometryEffect(id: bottomCard.rawValue, in: animation)
                                                .onTapGesture {
                                                    if selectedFieldIndex == index {
                                                        selectedFieldIndex = -1
                                                    } else {
                                                        selectedFieldIndex = index
                                                    }
                                                }
                                            if let topCard {
                                                CardView(card: topCard)
                                                    .frame(height: cardSize)
                                                    .offset(x: cardSize * 0.1, y: cardSize * 0.5)
                                                    .matchedGeometryEffect(id: bottomCard.rawValue, in: animation)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, cardSize * 0.5)
                            }
                        }
                        
                        Spacer()
                        ZStack {
                            let deck = Array(engine.deck.reversed())
                            ForEach(deck.indices, id: \.self) { index in
                                let card = deck[index]
                                let isLast = index == 0
                                
                                if isLast {
                                    CardView(card: card)
                                        .frame(height: cardSize)
                                        .rotationEffect(.degrees(90))
                                        .offset(x: cardSize * -0.3)
                                        .matchedGeometryEffect(id: card.rawValue, in: animation)
                                } else {
                                    Color.cyan
                                        .frame(width: cardSize * 0.66, height: cardSize)
                                        .cornerRadius(cardSize * 0.07)
                                        .matchedGeometryEffect(id: card.rawValue, in: animation)
                                        
                                }
                            }
                            
                            if started {
                                engine.trump.image
                                    .font(.title)
                                    .foregroundColor(engine.trump.color)
                            }
                        }
                        
                    }
                    
                    Spacer()
                    
                    if let winPlayer = engine.winPlayer {
                        Text(winPlayer == .first ? "Вы выиграли" : "Вы проиграли")
                            .font(.title)
                            .foregroundColor(.white)
                    } else {
                        Text(engine.priorityPlayer == .first ? "Вы ходите" : "Ходит другой игрок")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 5) {
                            ForEach(engine.firstPlayerCards, id: \.rawValue) { card in
                                CardView(card: card)
                                    .frame(height: cardSize)
                                    .matchedGeometryEffect(id: card.rawValue, in: animation)
                                    .onTapGesture {
                                        withAnimation {
                                            if engine.put(card, player: .first, fieldCardIndex: selectedFieldIndex) {
                                                selectedFieldIndex = engine.field.firstIndex(where: { $0.1 == nil }) ?? -1
                                            } else {
                                                selectedFieldIndex = -1
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.vertical)
                    }
                    let enabled1 = (engine.field.map({ $0.1 }).contains(nil) ? engine.priorityPlayer == .second : engine.priorityPlayer == .first) && engine.field.count > 0
                    Button(action: {
                        withAnimation {
                            engine.done()
                        }
                    }, label: {
                        Text("Готово")
                    })
                    .disabled(!enabled1)
                    .opacity(enabled1 ? 1 : 0.3)
                }
            }
            .padding()
        }
    }
}
