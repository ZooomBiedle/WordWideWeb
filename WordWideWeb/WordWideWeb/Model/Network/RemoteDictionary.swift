//
//  RemoteDictionary.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/17/24.
//

import UIKit

struct Item {
    var word, pos: String
    var sense: [SenseElement]
}

struct SenseElement {
    var senseOrder: Int
    var definition, transWord, transDfn: String
}
