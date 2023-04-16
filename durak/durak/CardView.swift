//
//  CardView.swift
//  durak
//
//  Created by Кирилл Иванников on 15.04.2023.
//

import SwiftUI

struct CardView: View {
    let card: Card
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.height
            
            ZStack {
                Color.white
                
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Text(card.denomination.text)
                                .font(.system(size: size * 0.15))
                        }
                        
                        Spacer()
                        
                        card.suit.image
                            .font(.system(size: size * 0.1))
                        
                        Spacer()
                            .frame(height: size * 0.15)
                        
                        card.suit.image
                            .rotationEffect(.degrees(180))
                            .font(.system(size: size * 0.1))
                        
                        Spacer()
                        
                        HStack {
                            Text(card.denomination.text)
                                .font(.system(size: size * 0.15))
                                .rotationEffect(.degrees(180))
                            Spacer()
                        }
                    }
                    .padding(.horizontal, size * 0.05)
                    .padding(.vertical, size * 0.01)
                    .border(card.suit.color, width: size * 0.005)
                }
                .foregroundColor(card.suit.color)
                .padding(size * 0.07)
            }
            .cornerRadius(size * 0.07)
        }
        .aspectRatio(0.66, contentMode: .fit)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        let card = Card(.ace, of: .club)
        
        ZStack {
            Color.green.ignoresSafeArea(.all)
            
            CardView(card: card)
                .frame(height: 500)
        }
    }
}
