//
//  TestResultViewController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/20/24.
//

import UIKit
import FirebaseAuth

class TestResultViewController: UIViewController {
    
    // MARK: - properties
    private let testView = TestResultView()
    var testResultWordbookId: String = ""
    var block: [[String:String]] = []
    var result: [Status] = []
    var wrongwordList: [String] = []
    
    private var rightCount = 0 {
        didSet {
            testView.bind(quizNum: quizCount, rightNum: rightCount, wrongNum: wrongCount)
        }
    }
    private var wrongCount = 0 {
        didSet {
            testView.bind(quizNum: quizCount, rightNum: rightCount, wrongNum: wrongCount)
        }
    }
    private var quizCount = 0 {
        didSet {
            testView.bind(quizNum: quizCount, rightNum: rightCount, wrongNum: wrongCount)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = self.testView
        setData()
        makeWrongWordsList()
        updateUserBlockCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.setNeedsDisplay()
    }
    
    private func setData(){
        testView.wrongwordLabel.dataSource = self
        testView.wrongwordLabel.delegate = self
        testView.wrongwordLabel.register(BlockCell.self, forCellWithReuseIdentifier: "BlockCell")
        testView.okBtn.addTarget(self, action: #selector(okBtnDidTapped), for: .touchUpInside)
    }
    
    @objc func okBtnDidTapped(){
        let tabBar = TabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        //해당 단어장 삭제
        deleteWordbook()
        present(tabBar, animated: true)
    }
    
    private func deleteWordbook(){
        Task {
            do {
                try await FirestoreManager.shared.deleteWordbook(withId: testResultWordbookId)
                //fetchWordbooks() // 삭제 후 단어장 목록 갱신
            } catch {
                print("Error deleting wordbook: \(error.localizedDescription)")
            }
        }
    }
    
    func bind(status: [Status]){
        self.result = status
        calculateScore()
    }
    
    private func calculateScore(){
        quizCount = result.count
        testView.quizNumLabel.text = String(result.count)
        for res in result{
            switch res {
            case .right:
                rightCount += 1
            case .wrong:
                wrongCount += 1
            case .none:
                wrongCount += 1
            }
        }
    }
    
    private func makeWrongWordsList(){
        var index = 0
        for res in result {
            print("res \(res)")
            if res != .right {
                if let wrongword = block[index]["term"] {
                    print(wrongword)
                    wrongwordList.append(wrongword)
                }
            }
            index += 1
        }
    }
    
    private func updateUserBlockCount(){
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            return
        }
        Task{
            do {
                let userInfo = try await FirestoreManager.shared.fetchUser(uid: user.uid)
                let blockNum = userInfo?.blockCount
                if let blocknum = blockNum {
                    let updateCount = blocknum + rightCount
                    try await FirestoreManager.shared.updateWordCount(for: user.uid, blockCount: updateCount)
                }
            } catch {
                throw error
            }
        }
        
    }
    
}

extension TestResultViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wrongCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlockCell", for: indexPath) as! BlockCell
        cell.bind(text: wrongwordList[indexPath.row])
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = wrongwordList[indexPath.row]
        let font = UIFont.systemFont(ofSize: 16)
        let textWidth = text.size(withAttributes: [NSAttributedString.Key.font: font]).width
        let cellWidth = textWidth + 20
        return CGSize(width: cellWidth, height: 28)
    }
    
}

