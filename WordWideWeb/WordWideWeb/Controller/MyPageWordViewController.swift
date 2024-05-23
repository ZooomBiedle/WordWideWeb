//
//  MyPageWordViewController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/21/24.
//

import UIKit
import SnapKit

// 단어카드 다음페이지 : 단어 리스트 페이지
class MyPageWordViewController: UIViewController, UIViewControllerTransitioningDelegate {

    var bookID: String = ""
    var wordsList: [Word] = []
    var selectedIndexPath: IndexPath?
    
    
    private let wordViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
<<<<<<< HEAD
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 30
=======
        layout.minimumLineSpacing = 30
        layout.minimumInteritemSpacing = 10
        
>>>>>>> dev
        return layout
    }()
    
    lazy var wordsCollecView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: wordViewFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
<<<<<<< HEAD
=======
        collectionView.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
>>>>>>> dev
        return collectionView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        setCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .modalDismissed, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .modalDismissed, object: nil)
    }
    
    private func fetchData() {
        Task {
            do {
                let words = try await FirestoreManager.shared.fetchWords(for: bookID)
                self.wordsList.removeAll()
                self.wordsList.append(contentsOf: words)
                wordsCollecView.reloadData()
            } catch {
                print("Error fetching words")
            }
        }
    }
    
    private func setCollectionView() {
        wordsCollecView.register(BlockCell.self, forCellWithReuseIdentifier: "BlockCell")

        self.view.addSubview(wordsCollecView)
        wordsCollecView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(100)
            make.horizontalEdges.equalToSuperview().inset(25)
            make.bottom.equalToSuperview()
        }
    }
    private func makeShadow(cell: UICollectionViewCell) {
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 3
    }
    
    @objc private func handleModalDismissed() {
        if let indexPath = selectedIndexPath {
            selectedIndexPath = nil
            wordsCollecView.performBatchUpdates(nil, completion: nil)
            if let cell = wordsCollecView.cellForItem(at: indexPath) as? BlockCell {
                cell.backgroundColor = .white
                cell.term.backgroundColor = .white
                cell.term.textColor = .black
                cell.term.font = .pretendard(size: 14, weight: .regular)
            }
        }
    }
    

}

extension MyPageWordViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlockCell", for: indexPath) as! BlockCell
        let text = wordsList[indexPath.item].term
        cell.bind(text: text)
        cell.term.font = UIFont.pretendard(size: 14, weight: .semibold)
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 5
        self.makeShadow(cell: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = wordsList[indexPath.item].term
        let font = UIFont.systemFont(ofSize: 14)
        let textWidth = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font]).width
        let cellWidth = textWidth + 20
        
        if selectedIndexPath == indexPath {
            return CGSize(width: cellWidth + 10, height: 38) // 선택된 셀의 크기 조정
        }
        
        return CGSize(width: cellWidth, height: 28)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let previousSelectedIndexPath = selectedIndexPath, let previousCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? BlockCell {
            previousCell.backgroundColor = .white
            previousCell.transform = .identity
        }
        
        selectedIndexPath = indexPath
        collectionView.performBatchUpdates(nil, completion: nil)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? BlockCell {
            cell.backgroundColor = .black
            cell.term.backgroundColor = .black
            cell.term.textColor = .white
            cell.term.font = .pretendard(size: 17, weight: .semibold)
            UIView.animate(withDuration: 0.3) {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        }
        
        let myPageModalVC = MyPageModalViewController()
        let text = wordsList[indexPath.item].term
    
        myPageModalVC.term = text
        myPageModalVC.modalPresentationStyle = .formSheet
        if let sheet = myPageModalVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        self.present(myPageModalVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
<<<<<<< HEAD
        guard let cell = collectionView.cellForItem(at: indexPath) as? BlockCell else { return }
        cell.backgroundColor = .white
        cell.term.textColor = .black
=======
        selectedIndexPath = nil
        collectionView.performBatchUpdates(nil, completion: nil)
>>>>>>> dev
    }
    
}
                
