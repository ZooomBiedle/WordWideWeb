//
//  TestIntroViewController.swift
//  WordWideWeb
//
//  Created by 신지연 on 2024/05/17.
//

import UIKit
import Firebase

class TestIntroViewController: UIViewController {
    
    
    // MARK: - properties
    private let testView = TestIntroView()
    private var wordblocks: [Word] = []
    private let testViewController = TestViewController()
    
    var testWordBook: Wordbook = Wordbook(
        id: "2",
        ownerId: "owner456",
        title: "Advanced iOS Development",
        isPublic: false,
        dueDate: nil, // No due date
        createdAt: Timestamp(date: Date().addingTimeInterval(-2592000)), // 1 month ago
        attendees: ["user6", "user7"],
        sharedWith: ["user8"],
        colorCover: "red",
        wordCount: 1,
        words: [
            Word(id: "w3", term: "Closure", definition: "A self-contained block of functionality that can be passed around and used in your code.")
        ], maxAttendees: 10
    )
    
    // MARK: - life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view = self.testView
        setData()
        getWords()
    }
    
    // MARK: - method
    
    private func setData(){
        testView.bind(title: testWordBook.title, blockCount: testWordBook.wordCount)
        testView.startBtn.addTarget(self, action: #selector(didTappedStartBtn), for: .touchUpInside)
    }
    
    private func getWords(){
        let id = testWordBook.id
        Task {
            do {
                self.wordblocks = try await FirestoreManager.shared.fetchWords(for: id)
            } catch {
                print("Error fetching wordbooks: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func didTappedStartBtn() {
        bind()
        testViewController.modalPresentationStyle = .fullScreen
        present(testViewController, animated: true)
    }
    
    private func bind() {
        testViewController.secondLeft = testWordBook.wordCount * 10
        testViewController.block = wordblocks.map { ["term": $0.term, "definition": $0.definition] }
        testViewController.taskname = testWordBook.title
        testViewController.taskmem = testWordBook.attendees
        testViewController.testingWordbookId = testWordBook.id
    }
}

