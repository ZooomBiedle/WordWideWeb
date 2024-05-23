//
//  InvitingVC.swift
//  WordWideWeb
//
//  Created by 박준영 on 5/17/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class InvitingVC: UIViewController {
    
    lazy var topLabel = LabelFactory().makeLabel(text: "Notify")
    
    lazy var topLogo = ImageFactory().makeImage()
    
    private let tableview = UITableView()
    
    private let pushNotificationHelper = PushNotificationHelper.shared
    
    private var invitationList: [InvitationViewData] = [] // 네트워크로 받아올 데이터
    
    var openedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchInvitations() // 뷰가 나타날 때마다 초대장 불러오기
    }
    
    func configureUI() {
        self.view.backgroundColor = UIColor(named: "bgColor")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableview.register(DefaultTableViewCell.self, forCellReuseIdentifier: DefaultTableViewCell.identifier)
        tableview.register(ExpandableTableViewCell.self, forCellReuseIdentifier: ExpandableTableViewCell.identifier)
        self.tableview.backgroundColor = UIColor(named: "bgColor")
        self.tableview.dataSource = self
        self.tableview.delegate = self
    }
    
    func setConstraints() {
        view.addSubview(topLabel)
        view.addSubview(topLogo)
        view.addSubview(tableview)
        
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(60)
        }
        
        topLogo.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(20)
            make.centerY.equalTo(topLabel.snp.centerY)
            make.width.height.equalTo(28)
        }
        
        tableview.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(24)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func fetchInvitations() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                self.invitationList = try await FirestoreManager.shared.fetchInvitations(for: userId)
                self.tableview.reloadData()
                for invitation in invitationList {
                    let dueDate = invitation.dueDate
                    let id = invitation.wordbookId
                    let title = invitation.title
                    guard let dueDateComponents = convertToDateComponents(from: dueDate) else { return  }
                    pushNotificationHelper.pushNotification(test: title, time: dueDateComponents, identifier: "\(id)")
                    
                }
            } catch {
                print("Error fetching invitations: \(error)")
            }
        }
    }
    
    private func convertToDateComponents(from dueDate: String) -> DateComponents? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대로 설정
        
        guard let date = dateFormatter.date(from: dueDate) else {
            print("Invalid date format")
            return nil
        }
        
        // Date를 DateComponents로 변환
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        return components
    }
}

extension InvitingVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitationList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return invitationList[indexPath.row].open ? 220 : 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let invitation = invitationList[indexPath.row]
        let imageURL = URL(string: invitation.photoURL ?? "")
        let formattedDate = DateFormatter.localizedString(from: invitation.createdAt, dateStyle: .short, timeStyle: .short)
        
        if !invitation.open {
            let cell = tableView.dequeueReusableCell(withIdentifier: DefaultTableViewCell.identifier, for: indexPath) as! DefaultTableViewCell
            cell.configure(title: invitation.title, date: formattedDate, imageURL: imageURL)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTableViewCell.identifier, for: indexPath) as! ExpandableTableViewCell
            cell.configure(title: invitation.title, date: formattedDate, imageURL: imageURL)
            cell.bindExpandedView(words: invitation.words)
            cell.rejectButtonAction = { [weak self] in
                Task {
                    do {
                        let invitationToReject = Invitation(
                            id: invitation.id,
                            from: invitation.ownerId,
                            to: Auth.auth().currentUser!.uid,
                            wordbookId: invitation.wordbookId,
                            title: invitation.title,
                            timestamp: Timestamp(date: invitation.createdAt),
                            dueDate: nil
                        )
                        try await FirestoreManager.shared.declineInvitation(invitation: invitationToReject)
                        DispatchQueue.main.async {
                            self?.invitationList.remove(at: indexPath.row)
                            self?.tableview.deleteRows(at: [indexPath], with: .automatic)
                        }
                    } catch {
                        print("Error declining invitation: \(error)")
                    }
                }
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [invitation.id])
            }
            cell.acceptButtonAction = { [weak self] in
                Task {
                    do {
                        let invitationToAccept = Invitation(
                            id: invitation.id,
                            from: invitation.ownerId,
                            to: Auth.auth().currentUser!.uid,
                            wordbookId: invitation.wordbookId,
                            title: invitation.title,
                            timestamp: Timestamp(date: invitation.createdAt),
                            dueDate: nil
                        )
                        try await FirestoreManager.shared.acceptInvitation(invitation: invitationToAccept)
                        DispatchQueue.main.async {
                            self?.invitationList.remove(at: indexPath.row)
                            self?.tableview.deleteRows(at: [indexPath], with: .automatic)
                        }
                    } catch {
                        print("Error accepting invitation: \(error)")
                    }
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        invitationList[indexPath.row].open.toggle()
        let section = IndexSet(integer: indexPath.section)
        tableView.reloadSections(section, with: .fade)
    }
}

