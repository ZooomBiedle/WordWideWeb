//
//  LaunchView.swift
//  WordWideWeb
//
//  Created by David Jang on 5/23/24.
//

import SwiftUI

public struct LaunchView: View {
    
    @State private var positions: [CGPoint]
    let words: [String]
    
    public init() {
        self.words = "Labyrinth,Ineffable,Incendiary,Ephemeral,Cynosure,Propinquity,Infatuation,Incandescent,Eudaemonia,Raconteur,Petrichor,Sumptuous,Aesthete,Nadir,Miraculous,Lassitude,Gossamer,Bungalow,Aurora,Inure,Mellifluous,Euphoria,Cherish,Demure,Elixir,Eternity,Felicity,Languor,Love,Solitude,Epiphany,Quintessential,Plethora,Nemesis,Lithe,Tranquility,Elegance,Renaissance,Eloquence,Sequoia,Peace,Lullaby,Paradox,Pristine,Effervescent,Opulence,Ethereal,Sanguine,Panacea,Bodacious,Axiom,Silhouette,Surreptitious,Ingenue,Dulcet,Tryst,Ebullience".components(separatedBy: ",")
        self._positions = State(initialValue: Array(repeating: .zero, count: words.count))
    }
    
    public var body: some View {
        ZStack {
            GeometryReader { proxy in
                let midX = proxy.size.width / 2.0
                let midY = proxy.size.height / 2.0
                ZStack {
                    Color.clear
                    ForEach(Array(self.words.enumerated()), id: \.offset) { index, word in
                        Text(word)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(index % 2 == 0 ? Color.secondary : Color.primary)
                            .position(positions[index])
                            .onAppear {
                                moveWord(index: index, in: proxy.size)
                            }
                    }
                }
                .onAppear {
                    for index in 0..<positions.count {
                        positions[index] = CGPoint(x: midX, y: midY)
                    }
                }
            }
        }
    }
    
    private func moveWord(index: Int, in size: CGSize) {
        withAnimation(Animation.linear(duration: Double.random(in: 3...6)).repeatForever(autoreverses: true)) {
            positions[index] = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
        }
    }
}

struct RandomAnimateText_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
