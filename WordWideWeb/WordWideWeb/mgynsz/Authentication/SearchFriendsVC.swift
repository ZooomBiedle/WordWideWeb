//
//  SearchFriendsVC.swift
//  WordWideWeb
//
//  Created by David Jang on 5/17/24.
//

import UIKit
import FirebaseAuth
import SnapKit

class SearchFriendsVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var onFriendsSelected: (([User]) -> Void)?
    var selectedFriends: [User] = []
    
    var maxInvitesAllowed: Int = 100
    
    private let searchBar = SearchBarWhite(frame: .zero, placeholder: "Search members..", cornerRadius: 10)
    private let tableView = UITableView()
    private let sendButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    
    private var friends: [User] = []
    private var searchTask: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor")
        setupViews()
        setupConstraints()
        setupSendButton()
        updateSendButtonState()
    }
    
    private func setupViews() {
        view.addSubview(searchBar)
        view.addSubview(closeButton)
        view.addSubview(tableView)
        view.addSubview(sendButton)
        
        searchBar.delegate = self
        searchBar.placeholder = "Search friends..."
        searchBar.backgroundColor = .white
        searchBar.barStyle = .black
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        
        tableView.backgroundColor = UIColor(named: "bgColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.identifier)
        tableView.tableFooterView = UIView()
        
    }
    
    private func setupConstraints() {

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(24)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(48)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(24)
            make.left.right.equalTo(view)
            make.bottom.equalTo(sendButton.snp.top).offset(-20)
        }
        
        sendButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(52)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.left.equalTo(view).offset(20)
        }
        
    }
    
    private func setupSendButton() {
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = UIColor(named: "mainBtn")
        sendButton.layer.cornerRadius = 10
        sendButton.isEnabled = false
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func searchFriends(with query: String) async {
        do {
            let users: [User]
            if query.contains("@") {
                users = try await FirestoreManager.shared.searchUserByEmail(query: query)
            } else {
                users = try await FirestoreManager.shared.searchUserByName(query: query)
            }
            self.friends = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error searching friends: \(error.localizedDescription)")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            guard !searchText.isEmpty else {
                self.friends = []
                self.tableView.reloadData()
                return
            }
            Task {
                await self.searchFriends(with: searchText)
            }
        }
        
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }
    
    @objc private func selectButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? FriendCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        let friend = friends[indexPath.row]
        
        if let index = selectedFriends.firstIndex(of: friend) {
            selectedFriends.remove(at: index)
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
            sender.tintColor = .black
        } else if selectedFriends.count < maxInvitesAllowed - 1 {  // 최대 초대 인원 - 1 (자기 자신 제외)
            selectedFriends.append(friend)
            sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            sender.tintColor = UIColor(named: "pointGreen")
        }
        
        updateSendButtonState()
    }
    
    private func updateSendButtonState() {
        sendButton.isEnabled = !selectedFriends.isEmpty
    }
    
    @objc private func sendButtonTapped() {
        onFriendsSelected?(selectedFriends)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.identifier, for: indexPath) as! FriendCell
        let friend = friends[indexPath.row]
        cell.configure(with: friend)
        
        if selectedFriends.contains(friend) {
            cell.selectButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            cell.selectButton.tintColor = UIColor(named: "pointGreen")
        } else {
            cell.selectButton.setImage(UIImage(systemName: "circle"), for: .normal)
            cell.selectButton.tintColor = .gray
        }
        
        cell.backgroundColor = UIColor(named: "bgColor")
        
        cell.selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

