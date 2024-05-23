//
//  InvitationData.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import Foundation
import FirebaseFirestore


struct ReceivedInvitation {
    let id: String    //
    let ownerId: String    //
    let photoURL: String?
    let title: String
    let dueDate: String
    let createdAt: Date
    let words: [String]
}

struct InvitationViewData {
    let id: String
    let ownerId: String
    let to: String // 초대받은 사용자의 uid
    let wordbookId: String // 단어장의 id
    let photoURL: String?
    let title: String
    let dueDate: String
    let createdAt: Date
    let words: [String]
    var open: Bool = false
    
    func toInvitation() -> Invitation {
        return Invitation(
            id: id,
            from: ownerId,
            to: to,
            wordbookId: wordbookId,
            title: title,
            timestamp: Timestamp(date: createdAt),
            dueDate: Timestamp(date: Date()) // 실제 초대 날짜로 설정
        )
    }
}


//func map(_ words: [ReceivedInvitation]) -> [[InvitationData]] {
//    words.map(map)
//        .unique()
//        .sorted()
//        .reduce(into: [[InvitationData]]()) { acc, day in
//            let wordsHavingSameData = words.filter { map($0) == day }
//                .map { InvitationData(id: $0.id, ownerId: $0.ownerId, photoURL: $0.photoURL, title: $0.title, dueDate: $0.dueDate, createdAt: map($0), words: $0.words)
//                }
//            acc.append(wordsHavingSameData)
//        }
//}

func map(_ word: ReceivedInvitation) -> Int {
    Calendar.current.component(.day, from: word.createdAt)
}

extension Array where Element == Int {
    func unique() -> Self {
        Array(Set(self))
    }
}

