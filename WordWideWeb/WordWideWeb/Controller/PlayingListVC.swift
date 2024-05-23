//
//  PlayingListViewController.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/16/24.
//

import UIKit
import Firebase

class PlayingListVC: UIViewController {
    
    // MARK: - properties
    private let playlistView = PlayingListView()
    private var selectedIndexPath: IndexPath?
    private var searchWord: String = ""
    private var wordTerms: [Word] = []
    private let pushNotificationHelper = PushNotificationHelper.shared
    var wordBooks: [Wordbook] = [ ]
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view = self.playlistView
        setData()
        setBtn()
        setUI()
        setDataForTrending()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadDataForResult()
    }
    
    // MARK: - method
    func setData(){
        playlistView.resultView.dataSource = self
        playlistView.resultView.delegate = self
        playlistView.resultView.register(PlayingListViewCell.self, forCellReuseIdentifier: "PlayingListViewCell")
    }
    
    private func filterData(){
        wordBooks = wordBooks.filter { $0.attendees.count < $0.maxAttendees }
        let currentDate = Date()
        wordBooks = wordBooks.filter {
            guard let dueDateTimestamp = $0.dueDate else {
                return false
            }
            let dueDate = dueDateTimestamp.dateValue()
            return dueDate > currentDate
        }
    }
    
    private func setDataForTrending(){
        Task {
            do {
                self.wordBooks = try await FirestoreManager.shared.fetchAllWordbooks()
                self.wordBooks.sort { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
                filterData() // 생성 날짜로 정렬
                self.playlistView.resultView.reloadData()
            } catch {
                print("Error fetching wordbooks: \(error.localizedDescription)")
            }
        }
    }
    
    private func setDataForSearchWord(keyword: String){
        Task {
            do {
                self.wordBooks = try await FirestoreManager.shared.fetchWordbooksByTitle(for: keyword)
                self.wordBooks.sort { $0.createdAt.dateValue() > $1.createdAt.dateValue() }
                filterData()
                self.playlistView.resultView.reloadData()
            } catch {
                print("Error fetching wordbooks: \(error.localizedDescription)")
            }
        }
    }
    
    private func setUI(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setBtn(){
        let popUpButtonClosure = { [self] (action: UIAction) in
            if action.title == "생성순" {
                wordBooks.sort { book1, book2 in
                    let date1 = convertTimestampToString(timestamp: book1.createdAt)
                    let date2 = convertTimestampToString(timestamp: book2.createdAt)
                    return date1 < date2
                }
            } else {
                wordBooks.sort { book1, book2 in
                    let date1 = convertTimestampToString(timestamp: book1.dueDate)
                    let date2 = convertTimestampToString(timestamp: book2.dueDate)
                    return date1 < date2
                }
            }
            self.playlistView.resultView.reloadData()
        }
        
        playlistView.filterBtn.menu = UIMenu(
            title: "정렬",
            image: UIImage.filter,
            options: .displayInline,
            children: [
                UIAction(title: "생성순", handler: popUpButtonClosure),
                UIAction(title: "마감순", handler: popUpButtonClosure),]
        )
        
        playlistView.filterBtn.showsMenuAsPrimaryAction = true
        playlistView.filterBtn.changesSelectionAsPrimaryAction = true
    }
    
    private func convertTimestampToString(timestamp: Timestamp?) -> String {
        guard let timestamp = timestamp else {
            return "No Date" // 타임스탬프가 nil일 경우 처리
        }
        
        let date = timestamp.dateValue() // Timestamp를 Date로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd h:mm a" // 날짜 형식 설정
        return dateFormatter.string(from: date) // Date를 문자열로 변환하여 반환
    }
    
    @objc func joinBtnDidTapped(_ sender: UIButton){
        guard let cell = sender.superview?.superview as? PlayingListViewCell,
              let indexPath = playlistView.resultView.indexPath(for: cell) else {
            return
        }
        
        let wordbookId = wordBooks[indexPath.row].id
        let dueDate = wordBooks[indexPath.row].dueDate
        let title = wordBooks[indexPath.row].title
        guard let dueDateComponents = convertToDateComponents(from: dueDate) else { return  }
        pushNotificationHelper.pushNotification(test: title, time: dueDateComponents, identifier: "\(wordbookId)")
        joinWordBook(for: wordbookId)
    }
    
    private func joinWordBook(for wordbookId: String){
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            return
        }
        Task {
            do {
                let isAdded = try await FirestoreManager.shared.addAttendee(to: wordbookId, attendee: user.uid)
                if isAdded {
                    showAlert(message: "단어장 목록에 추가되었습니다.")
                } else {
                    showAlert(message: "이미 참여중인 단어장입니다.")
                }
            } catch {
                print("Failed to add word: \(error.localizedDescription)")
            }
        }
    }
    
    private func convertToDateComponents(from timestamp: Timestamp?) -> DateComponents? {
        guard let timestamp = timestamp else { return nil }
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return components
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        reloadDataForResult()
        playlistView.resultView.reloadData()
        present(alert, animated: true, completion: nil)
    }
    
    private func reloadDataForResult() {
        if searchWord == "" {
            setDataForTrending()
        } else {
            setDataForSearchWord(keyword: searchWord)
        }
    }
}

extension PlayingListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWord = searchText
        if searchWord == "" {
            setDataForTrending()
        } else {
            setDataForSearchWord(keyword: searchWord)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func getWords(for wordbookId: String) async throws -> [Word] {
        do {
            let words = try await FirestoreManager.shared.fetchWords(for: wordbookId)
            return words
        } catch {
            print("Error fetching words: \(error.localizedDescription)")
            throw error
        }
    }
}

extension PlayingListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayingListViewCell", for: indexPath) as? PlayingListViewCell else {
            return UITableViewCell()
        }
        let title = wordBooks[indexPath.row].title
        let date = convertTimestampToString(timestamp: wordBooks[indexPath.row].dueDate)
        let owner =  wordBooks[indexPath.row].ownerId
        cell.listview.bind(imageData: Data(), title: title, date: date)
        cell.joinButton.addTarget(self, action: #selector(joinBtnDidTapped), for: .touchUpInside)
        
        let wordbookId = wordBooks[indexPath.row].id
        Task {
            do {
                let words = try await getWords(for: wordbookId)

                DispatchQueue.main.async {
                    self.wordBooks[indexPath.row].words = words
                    cell.wordList = self.wordBooks[indexPath.row].words.map { $0.term }
                    cell.wordbookId = wordbookId
                    
                    cell.nowPplNum = self.wordBooks[indexPath.row].attendees.count
                    cell.pplNum = self.wordBooks[indexPath.row].maxAttendees
                    
                    // 이미지를 로드하여 셀에 설정
                    self.fetchImageAndSetImage(for: owner, imageView: cell.listview.imageLabel)
                }
            } catch {
                print("Error fetching words: \(error.localizedDescription)")
            }
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selectedIndexPath = tableView.indexPathForSelectedRow, selectedIndexPath == indexPath {
            if wordBooks[indexPath.row].words.count == 0 {
                return 120
            } else {
                return 170
            }
        } else {
            return 80
        }
    }
}



