//
//  MyPage.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import Foundation

struct MyPage {
    let word: [String]
    let title: String
    let name: String
    let image: String
    
    init(word: [String], title: String, name: String, image: String) {
        self.word = word
        self.title = title
        self.name = name
        self.image = image
    }
}
