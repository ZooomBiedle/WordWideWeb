//
//  DictionaryViewController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/17/24.
//

import UIKit
import SnapKit
import FirebaseAuth

class DictionaryVC: UIViewController {
    
    private let logo: UILabel = {
        let label = UILabel()
        label.text = "Add Word"
        label.font = UIFont.pretendard(size: 20, weight: .semibold)
        return label
    }()
    private var searchBar = SearchBarWhite(frame: .zero, placeholder: "추가할 단어를 입력하세요", cornerRadius: 10)
    private lazy var tableview = UITableView()
    
    private var receivedItem: [Item] = [] {
        didSet {
            tableview.reloadData()
        }
    }
    
    // addButton 누르면 보여질 단어장 배열
    private var wordbooks: [Wordbook] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setConstraints()
        // 단어장 불러오기
        fetchWordbooks()
    }
    
    func configureUI() {
        self.view.backgroundColor = UIColor(named: "bgColor")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.searchBar.delegate = self
        searchBar.backgroundColor = .white
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.borderColor = UIColor.white.cgColor
        
        self.tableview.dataSource = self
        tableview.register(DictionaryTableViewCell.self, forCellReuseIdentifier: DictionaryTableViewCell.identifier)
        self.tableview.backgroundColor = UIColor(named: "bgColor")
    }
    
    func setConstraints() {
        [logo, searchBar, tableview].forEach {
            self.view.addSubview($0)
        }
        
        logo.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        tableview.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    // 단어장 추가 메서드
    private func fetchWordbooks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                wordbooks = try await FirestoreManager.shared.fetchWordbooks(for: userId)
                tableview.reloadData()
            } catch {
                print("Failed to fetch wordbooks: \(error.localizedDescription)")
            }
        }
    }
}


extension DictionaryVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        print("Search query: \(keyword)")
        NetworkManager.shared.fetchAPI(query: keyword) { [weak self] items in
            guard let self else { return }
            print("Items received: \(items.count)")
            self.receivedItem = items
        }
    }
}


extension DictionaryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DictionaryTableViewCell.identifier, for: indexPath) as! DictionaryTableViewCell
        
        let index = receivedItem[indexPath.row]
        cell.wordLabel.text = index.word
        cell.setStackView(item: index)
        
        // 단어장을 선택하는 액션 시트를 설정합니다.
        cell.addButtonAction = { [weak self] in
            guard let self = self else { return }
            self.fetchWordbooks()
            self.presentWordbookActionSheet(for: index)
        }
        
        return cell
    }
    
    private func presentWordbookActionSheet(for item: Item) {
        let alert = UIAlertController(title: "Select Wordbook", message: nil, preferredStyle: .actionSheet)
//        alert.view.backgroundColor = .red
//        alert.isSpringLoaded = true
//        alert.severity = .critical
//        alert.viewIfLoaded?.backgroundColor = .red
        
        
        wordbooks.forEach { wordbook in
            let action = UIAlertAction(title: wordbook.title, style: .default) { [weak self] _ in
                self?.addWord(item, to: wordbook)
            }
            alert.addAction(action)
        }
        
        let createAction = UIAlertAction(title: "Create New Wordbook", style: .destructive) { [weak self] _ in
            self?.presentAddWordbookVC()
        }
        alert.addAction(createAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func addWord(_ item: Item, to wordbook: Wordbook) {
        // Firestore에 단어를 추가합니다.
        let word = Word(id: UUID().uuidString, term: item.word, definition: item.sense.map { $0.transWord }.joined(separator: ", "))
        
        Task {
            do {
                let isAdded = try await FirestoreManager.shared.addWord(to: wordbook.id, word: word)
                if isAdded {
                    showAlert(message: "\(wordbook.title)에 저장되었습니다.")
                } else {
                    showAlert(message: "\(wordbook.title)에 이미 추가 된 단어입니다.")
                }
            } catch {
                print("Failed to add word: \(error.localizedDescription)")
            }
        }
    }
    
    private func presentAddWordbookVC() {
        let addWordBookVC = AddWordBookVC()
        addWordBookVC.modalPresentationStyle = .formSheet
        present(addWordBookVC, animated: true, completion: nil)
    }
}

