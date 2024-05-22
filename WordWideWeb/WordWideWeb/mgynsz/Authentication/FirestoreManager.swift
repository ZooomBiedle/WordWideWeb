//
//  FirestoreManager.swift
//  WordWideWeb
//
//  Created by David Jang on 5/17/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

final class FirestoreManager {
    static let shared = FirestoreManager()
    private init() { }
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var uploadTasks: [String: StorageUploadTask] = [:]
    
    // 사용자 정보 저장 또는 업데이트
    func saveOrUpdateUser(user: User) async throws {
        let userRef = db.collection("users").document(user.uid)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    // 기존 문서가 존재할 경우 업데이트
                    var dataToUpdate: [String: Any] = [:]
                    if !user.email.isEmpty {
                        dataToUpdate["email"] = user.email
                    }
                    if let displayName = user.displayName, !displayName.isEmpty {
                        dataToUpdate["displayName"] = displayName
                    }
                    if let photoURL = user.photoURL, !photoURL.isEmpty {
                        dataToUpdate["photoURL"] = photoURL
                    }
                    if let socialMediaLink = user.socialMediaLink, !socialMediaLink.isEmpty {
                        dataToUpdate["socialMediaLink"] = socialMediaLink
                    }
                    dataToUpdate["authProvider"] = user.authProvider.rawValue
                    
                    userRef.updateData(dataToUpdate) { error in
                        if let error = error {
                            print("Error updating user in Firestore: \(error)")
                            continuation.resume(throwing: error)
                        } else {
                            print("User updated in Firestore: \(user)")
                            continuation.resume(returning: ())
                        }
                    }
                } else {
                    // 기존 문서가 없을 경우 새로 생성
                    userRef.setData([
                        "uid": user.uid,
                        "email": user.email,
                        "displayName": user.displayName ?? "",
                        "photoURL": user.photoURL ?? "",
                        "socialMediaLink": user.socialMediaLink ?? "",
                        "authProvider": user.authProvider.rawValue
                    ]) { error in
                        if let error = error {
                            print("Error saving user to Firestore: \(error)")
                            continuation.resume(throwing: error)
                        } else {
                            print("User saved to Firestore: \(user)")
                            continuation.resume(returning: ())
                        }
                    }
                }
            }
        }
    }
    
    // 프로필 이미지 업로드
    func uploadProfileImage(_ image: UIImage, for userId: String) async throws -> URL {
        let storageRef = storage.reference().child("profile_images/\(userId).jpg")

        // 이전 업로드 작업 상태 확인
        if UserDefaults.standard.bool(forKey: "uploadInProgress_\(userId)") {
            throw NSError(domain: "Upload Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload already in progress"])
        }

        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(domain: "Upload Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }

        // 업로드 시작 상태 저장
        UserDefaults.standard.set(true, forKey: "uploadInProgress_\(userId)")

        return try await withCheckedThrowingContinuation { continuation in
            _ = storageRef.putData(imageData, metadata: nil) { metadata, error in
                // 업로드 완료 상태 저장
                UserDefaults.standard.set(false, forKey: "uploadInProgress_\(userId)")
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let downloadURL = url else {
                        continuation.resume(throwing: NSError(domain: "Upload Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"]))
                        return
                    }
                    continuation.resume(returning: downloadURL)
                }
            }
        }
    }
    
    func updateUserProfile(displayName: String?, photoURL: URL?, socialMediaLink: String?) async throws {
        guard let user = Auth.auth().currentUser else { return }

        var data: [String: Any] = [:]
        if let displayName = displayName {
            data["displayName"] = displayName
        }
        if let photoURL = photoURL {
            data["photoURL"] = photoURL.absoluteString
        }
        if let socialMediaLink = socialMediaLink {
            data["socialMediaLink"] = socialMediaLink
        }
        let userRef = db.collection("users").document(user.uid)
        try await userRef.updateData(data)
    }
    
    // 사용자 ㄱ
    func deleteUser(uid: String) async throws {
        // Firestore에서 사용자 문서 삭제
        let userRef = db.collection("users").document(uid)
        try await userRef.delete()
        
        // Storage에서 사용자 프로필 이미지 삭제
        let storageRef = storage.reference().child("profile_images/\(uid).jpg")
        do {
            try await storageRef.delete()
        } catch {
            print("Error deleting profile image: \(error.localizedDescription)")
        }
    }
    
    // 사용자 정보 가져오기
    func fetchUser(uid: String) async throws -> User? {
        let document = try await fetchDocument(collection: "users", documentID: uid)
        return try document.data(as: User.self)
    }
    
    // 여러 사용자의 정보를 가져오는 메서드
    func fetchUsers(uids: [String]) async throws -> [User] {
        guard !uids.isEmpty else { return [] }
        
        let documents = try await db.collection("users")
            .whereField("uid", in: uids)
            .getDocuments()
        
        return documents.documents.compactMap { try? $0.data(as: User.self) }
    }
    
    // 이메일로 사용자 검색
    func searchUserByEmail(query: String) async throws -> [User] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }
        
        let snapshot = try await db.collection("users")
            .whereField("email", isGreaterThanOrEqualTo: trimmedQuery)
            .whereField("email", isLessThanOrEqualTo: trimmedQuery + "\u{f8ff}")
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }
    
    // 이름으로 사용자 검색
    func searchUserByName(query: String) async throws -> [User] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }
        
        let snapshot = try await db.collection("users")
            .whereField("displayName", isGreaterThanOrEqualTo: trimmedQuery)
            .whereField("displayName", isLessThanOrEqualTo: trimmedQuery + "\u{f8ff}")
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }
    
    // 초대장 전송
    func sendInvitation(to recipientUID: String, wordbookId: String, title: String, dueDate: Timestamp?) async throws {
        let currentUserUID = Auth.auth().currentUser!.uid
        let invitation = Invitation(
            id: UUID().uuidString,
            from: currentUserUID,
            to: recipientUID,
            wordbookId: wordbookId,
            title: title,
            timestamp: Timestamp(date: Date()),
            dueDate: dueDate  // 제한 기한을 포함
        )
        
        let data = try Firestore.Encoder().encode(invitation)
        
        try await Firestore.firestore().collection("invitations").document(invitation.id).setData(data)
    }
    
//    // 공통 문서 가져오기 메서드
//    private func fetchDocument(collection: String, documentID: String) async throws -> DocumentSnapshot {
//        let document = try await db.collection(collection).document(documentID).getDocument()
//        guard document.exists else {
//            throw FirestoreError.documentNotFound
//        }
//        return document
//    }
    
    enum FirestoreError: Error {
        case documentNotFound
    }
    
    // 단어장 생성
    func createWordbook(wordbook: Wordbook) async throws {
        var data = try Firestore.Encoder().encode(wordbook)
        data["createdDate"] = FieldValue.serverTimestamp()
        data["hasDueDate"] = wordbook.dueDate != nil
        data["attendees"] = wordbook.attendees
        data["words"] = [] as [String]
        data["wordCount"] = 0

        let wordbookRef = db.collection("wordbooks").document(wordbook.id)
        try await wordbookRef.setData(data)

        // 참석자들에게 단어장 공유 정보 추가
        for attendeeId in wordbook.attendees {
            let userRef = db.collection("users").document(attendeeId)
            try await userRef.updateData([
                "sharedWordbooks": FieldValue.arrayUnion([wordbook.id])
            ])
        }
    }
    
    // 단어장 가져오기
    func fetchWordbooks(for userId: String) async throws -> [Wordbook] {
        let querySnapshot = try await db.collection("wordbooks")
            .whereField("ownerId", isEqualTo: userId)
            .getDocuments()
        
        var wordbooks: [Wordbook] = []
        
        for document in querySnapshot.documents {
            var wordbook = try document.data(as: Wordbook.self)
            let wordCount = try await fetchWordCount(for: wordbook.id)
            wordbook.wordCount = wordCount
            wordbooks.append(wordbook)
        }
        
        return wordbooks
    }
    
    // 단어장을 업데이트하는 메서드 예시
    func updateWordbook(_ wordbook: Wordbook) async throws {
        var updatedWordbook = wordbook
        updatedWordbook.wordCount = try await fetchWordCount(for: wordbook.id)
        updatedWordbook.words = try await fetchWords(for: wordbook.id)
        
        let data = try Firestore.Encoder().encode(updatedWordbook)
        
        try await db.collection("wordbooks").document(wordbook.id).setData(data)
    }

    // 단어 추가
    func addWord(to wordbookId: String, word: Word) async throws -> Bool {
        // 단어 중복 확인
        let words = try await fetchWords(for: wordbookId)
        if words.contains(where: { $0.term == word.term }) {
            return false // 이미 단어가 존재함
        }
        
        let data = try Firestore.Encoder().encode(word)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection("wordbooks").document(wordbookId).collection("words").document(word.id).setData(data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        
        // 단어를 추가한 후 단어장의 wordCount를 업데이트
        try await updateWordCount(for: wordbookId)
        return true // 새로운 단어가 추가됨
    }
    
    // 단어장의 wordCount 업데이트
    private func updateWordCount(for wordbookId: String) async throws {
        let wordCount = try await fetchWordCount(for: wordbookId)
        try await db.collection("wordbooks").document(wordbookId).updateData([
            "wordCount": wordCount
        ])
    }
    
    // 단어 개수 가져오기
    private func fetchWordCount(for wordbookId: String) async throws -> Int {
        let snapshot = try await db.collection("wordbooks").document(wordbookId).collection("words").getDocuments()
        return snapshot.documents.count
    }
    
    // 단어들을 가져오는 메서드
    private func fetchWords(for wordbookId: String) async throws -> [Word] {
        let snapshot = try await db.collection("wordbooks").document(wordbookId).collection("words").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Word.self) }
    }
    
    // 단어장 공개/비공개 설정
    func setWordbookVisibility(wordbookId: String, isPublic: Bool) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection("wordbooks").document(wordbookId).updateData(["isPublic": isPublic]) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    // 단어장 공유
    func shareWordbook(wordbookId: String, with userId: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection("wordbooks").document(wordbookId).updateData([
                "sharedWith": FieldValue.arrayUnion([userId])
            ]) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    // 공유 단어장 가져오기
    func fetchSharedWordbooks(for userId: String) async throws -> [Wordbook] {
        let userDoc = try await db.collection("users").document(userId).getDocument()
        guard let sharedWordbookIds = userDoc.data()?["sharedWordbooks"] as? [String] else {
            return []
        }
        
        var wordbooks: [Wordbook] = []
        
        try await withThrowingTaskGroup(of: Wordbook?.self) { group in
            for id in sharedWordbookIds {
                group.addTask {
                    let doc = try await self.db.collection("wordbooks").document(id).getDocument()
                    return try doc.data(as: Wordbook.self)
                }
            }
            
            for try await wordbook in group {
                if let wordbook = wordbook {
                    wordbooks.append(wordbook)
                }
            }
        }
        
        return wordbooks
    }
    
    // 단어장 삭제
    func deleteWordbook(withId wordbookId: String) async throws {
        let wordbookRef = db.collection("wordbooks").document(wordbookId)
        try await wordbookRef.delete()
    }
    
    // MARK: 초대 관련

    // 초대 전송
    func sendInvitation(to recipientUID: String, wordbookId: String, title: String) async throws {
        let currentUserUID = Auth.auth().currentUser!.uid
        let invitationData: [String: Any] = [
            "from": currentUserUID,
            "to": recipientUID,
            "wordbookId": wordbookId,
            "title": title,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("invitations").addDocument(data: invitationData)
    }

    // 초대 수락
    func acceptInvitation(invitation: Invitation) async throws {
        let userRef = db.collection("users").document(invitation.to)
        try await userRef.updateData([
            "sharedWordbooks": FieldValue.arrayUnion([invitation.wordbookId])
        ])
        
        let invitationRef = db.collection("invitations").document(invitation.id)
        try await invitationRef.delete()
    }

    // 초대 거절
    func declineInvitation(invitation: Invitation) async throws {
        let invitationRef = db.collection("invitations").document(invitation.id)
        try await invitationRef.delete()
    }
    
    // 초대 가져오기
//    func fetchInvitations(for userId: String) async throws -> [Invitation] {
//        let snapshot = try await db.collection("invitations").whereField("to", isEqualTo: userId).getDocuments()
//    }
    
    // MARK: - Helper Methods
    
    private func fetchDocument(collection: String, documentID: String) async throws -> DocumentSnapshot {
        return try await withCheckedThrowingContinuation { continuation in
            db.collection(collection).document(documentID).getDocument { document, error in
                if let document = document, document.exists {
                    continuation.resume(returning: document)
                } else {
                    continuation.resume(throwing: error ?? URLError(.badServerResponse))
                }
            }
        }
    }
    
    private func fetchDocuments(collection: String, field: String, value: String) async throws -> QuerySnapshot {
        return try await withCheckedThrowingContinuation { continuation in
            db.collection(collection).whereField(field, isEqualTo: value).getDocuments { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    continuation.resume(returning: querySnapshot)
                } else {
                    continuation.resume(throwing: error ?? URLError(.badServerResponse))
                }
            }
        }
    }
    
    private func fetchCollectionDocuments(collection: String) async throws -> QuerySnapshot {
        return try await withCheckedThrowingContinuation { continuation in
            db.collection(collection).getDocuments { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    continuation.resume(returning: querySnapshot)
                } else {
                    continuation.resume(throwing: error ?? URLError(.badServerResponse))
                }
            }
        }
    }
}
