//
//  TestViewController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/20/24.
//

import UIKit

enum Status {
    case right
    case wrong
    case none
}

class TestViewController: UIViewController {
    
    // MARK: - properties
    private let testView = TestView()
    var secondLeft: Int = 180
    
    var testingWordbookId: String = ""
    var taskname: String = ""
    var taskmem: [String] = []
    var block: [[String:String]] = []
    
    private var currentIndex: Int = 0
    private var answer: String = ""
    private var status: [Status] = []
    private var timer: Timer?
    private let resultVC = TestResultViewController()
    
    // MARK: - life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view = self.testView
        setData()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - method
    private func setData(){
        testView.friendView.register(TestFriendViewCell.self, forCellWithReuseIdentifier: "TestFriendViewCell")
        testView.friendView.dataSource = self
        testView.friendView.delegate = self
        testView.answerLabel.delegate = self
        testView.totalPageLabel.text = " of \(block.count)"
        testView.nextBtn.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        testView.beforeBtn.addTarget(self, action: #selector(beforeBtnTapped), for: .touchUpInside)
        testView.submitBtn.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        testView.beforeBtn.isEnabled = false

        status = Array(repeating: .none, count: block.count)
        
        setTimer()
        reloadQView()
    }
    
    private func setTimer(){
        secondLeft = block.count * 10
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (t) in
            //남은 시간(초)에서 1초 빼기
            self.secondLeft -= 1
            
            //남은 분
            let minutes = self.secondLeft / 60
            //그러고도 남은 초
            let seconds = self.secondLeft % 60
            
            //남은 시간(초)가 0보다 크면
            if self.secondLeft > 0 {
                self.testView.timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
            } else {
                self.timer?.invalidate()
                self.moveToResultView()
            }
        })
    }
    
    private func reloadQView(){
        if let def = block[currentIndex]["definition"] {
            testView.bindQ(page: currentIndex+1, definition: def)
        }
        if let word = block[currentIndex]["term"] {
            answer = word
        }
        switch status[currentIndex] {
        case .right:
            testView.answerLabel.isEnabled = false
            testView.submitBtn.isEnabled = false
            isAlreadySolveAndRight()
        case .wrong:
            testView.answerLabel.isEnabled = false
            testView.submitBtn.isEnabled = false
            isAlreadySolveAndWrong()
        case .none:
            testView.answerLabel.isEnabled = true
            testView.submitBtn.isEnabled = true
            isNotSolved()
        }
    }
    
    private func moveToResultView(){
        bind()
        resultVC.modalPresentationStyle = .fullScreen
        
        if self.presentedViewController == nil {
            self.present(resultVC, animated: true, completion: nil)
        } else if self.presentedViewController != resultVC {
            self.dismiss(animated: true) {
                self.present(self.resultVC, animated: true, completion: nil)
            }
        }
    }
    
    private func isAlreadySolveAndRight(){
        testView.questionView.layer.borderColor = UIColor.green.cgColor
        testView.questionView.layer.borderWidth = 2
        testView.submitBtn.isEnabled = false
    }
    
    private func isAlreadySolveAndWrong(){
        testView.questionView.layer.borderColor = UIColor.red.cgColor
        testView.questionView.layer.borderWidth = 2
        testView.submitBtn.isEnabled = false
    }
    
    private func isNotSolved(){
        testView.questionView.layer.borderWidth = 0
    }
    
    private func bind(){
        resultVC.block = self.block
        resultVC.bind(status: status)
        resultVC.testResultWordbookId = testingWordbookId
    }
    
    
    @objc private func checkAnswer(){
        guard let userInput = testView.answerLabel.text else {
            print("No answer entered")
            return
        }
        if answer == userInput {
            status[currentIndex] = .right
            reloadQView()
        } else {
            status[currentIndex] = .wrong
            reloadQView()
        }
        print(status)
        if !status.contains(.none){
            moveToResultView()
        }
    }
    
    @objc private func nextBtnTapped(){
        testView.answerLabel.text = ""
        if currentIndex < block.count - 2 {
            testView.beforeBtn.isEnabled = true
            currentIndex += 1
            reloadQView()
        } else if currentIndex == block.count - 2 {
            currentIndex += 1
            testView.nextBtn.isEnabled = false
            testView.beforeBtn.isEnabled = true
            reloadQView()
        } else {
            testView.nextBtn.isEnabled = false
            testView.nextBtn.isEnabled = true
        }
    }
    
    @objc private func beforeBtnTapped(){
        testView.answerLabel.text = ""
        if currentIndex == 1 {
            currentIndex -= 1
            testView.beforeBtn.isEnabled = false
            testView.nextBtn.isEnabled = true
            reloadQView()
        } else {
            currentIndex -= 1
            reloadQView()
            testView.nextBtn.isEnabled = true
        }
    }

}

// MARK: - extension
extension TestViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskmem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestFriendViewCell", for: indexPath) as! TestFriendViewCell
        fetchImageAndSetImage(for: taskmem[indexPath.row], imageView: cell.friendImage)
        return cell
    }
    
    func fetchImageAndSetImage(for id: String, imageView: UIImageView) {
        Task {
            do {
                if let url = try await fetchImage(id: id) {
                    imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(systemName: "person.crop.circle"))
                
                } else {
                    imageView.image = UIImage(systemName: "person.crop.circle")
                }
            } catch {
                print("Error fetching image: \(error.localizedDescription)")
                imageView.image = UIImage(systemName: "person.crop.circle")
            }
        }
    }
    
    func fetchImage(id: String) async throws -> String? {
        do {
            let user = try await FirestoreManager.shared.fetchUser(uid: id)
            return user?.photoURL
        } catch {
            print("Error fetching image: \(error.localizedDescription)")
            throw error
        }
    }
}

extension TestViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            let transform = CGAffineTransform(translationX: 0, y: -200)
            self.view.transform = transform
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkAnswer()
        return true
    }
}
