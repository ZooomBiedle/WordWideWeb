//
//  LaunchView.swift
//  WordWideWeb
//
//  Created by David Jang on 5/23/24.
//

import SwiftUI

public struct CircleAnimateText: View {
    
    @State private var isCircle: Bool = true
    @State private var angle: Angle = .zero
    @Namespace private var namespace
    let words: [String]
    
    public init() {
        self.words = "Hello,World,Swift,Programming,Apple,Code,Develop,App,Design,Function,Variable,Constant,Array,Dictionary,String,Int,Double,Float,Bool,Class,Struct,Enum,Protocol,Extension,Framework,Library,Package,Manager,Xcode,Simulator,Interface,Builder,Preview,Playground,Project,File,Folder,Commit,Push,Pull,Merge,Branch,Debug,Release,Profile,Test,Deploy,Version,Control,Git,Repository,Clone,Fetch".components(separatedBy: ",")
    }
    
    public var body: some View {
            ZStack {
                GeometryReader { proxy in
                    let midX = Int(proxy.size.width / 2.0)
                    let midY = Int(proxy.size.height / 2.0)
                    ZStack {
                        Color.clear
                        ForEach(Array(self.words.enumerated()), id: \.offset) { index, word in
                            Group {
                                if isCircle {
                                    RowView(word: word, width: CGFloat(min(midX, midY)), isCircle: true)
                                        .matchedGeometryEffect(id: index, in: namespace)
                                        .frame(width: min(proxy.size.width, proxy.size.height))
                                        .foregroundColor(index % 2 == 0 ? Color.secondary : Color.primary)
                                        .rotationEffect(.degrees(Double(index) / Double(self.words.count)) * 360)
                                } else {
                                    let scale = CGFloat.random(in: 0.2...0.6)
                                    RowView(word: word, width: CGFloat(min(midX, midY)), isCircle: false)
                                        .matchedGeometryEffect(id: index, in: namespace)
                                        .frame(width: min(proxy.size.width, proxy.size.height))
                                        .foregroundColor(index % 2 == 0 ? Color.secondary : Color.primary)
                                        .rotationEffect(Angle(degrees: CGFloat(Int.random(in: 0...360))))
                                        .offset(x: CGFloat(Int.random(in: -midX / 2...midX / 2)),
                                                y: CGFloat(Int.random(in: -midY / 2...midY / 2)))
                                        .scaleEffect(index % 2 == 0 ? scale * 2 : scale * 5.0)
                                }
                            }
                            .opacity(Double(index) / Double(words.count))
                        }
                        .rotationEffect(angle)
                    }
                }
                Text("WordWideWeb")
                    .font(.system(size: 36, weight: .semibold))
                    .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 0)
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 10.0).repeatForever(autoreverses: false)) {
                    angle = Angle(degrees: 360)
                }
            }
            .padding()
        }
    }

fileprivate
struct RowView: View {
    let word: String
    let width: CGFloat
    let isCircle: Bool
    
    var body: some View {
        HStack {
            Text(word)
                .font(.caption)
                .fontWeight(.bold)
                .fixedSize()
            if isCircle {
                Circle()
                    .frame(width: 5, height: 5)
                    .offset(x: -3)
            }
            Spacer()
        }
    }
}

struct CircleAnimateText_Previews: PreviewProvider {
    static var previews: some View {
        CircleAnimateText()
    }
}
