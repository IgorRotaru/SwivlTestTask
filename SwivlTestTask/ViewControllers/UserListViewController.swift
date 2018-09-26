//
//  UserListViewController.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/24/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit
import ObjectMapper
import INSPullToRefresh

class UserListViewController: SelectedUsersViewController {

	@IBOutlet weak var tblUserList: UITableView!
	
	private var lastSinceUserId: Int?
	private var pageLoading: Bool = false
	private var userList: [User] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Select Users"
		setupStatusBar(statusBarBgView: AppUtility.statusBarBgView)
		registerCells()
		addInfinityScroll()
		addNextBarBtn()
		loadUserListPage(sinceUserId: lastSinceUserId, completion: nil)
	}

	// MARK: - private
	
	private func registerCells() {
		let userListCellNib = UINib(nibName: UserListCell.identifier, bundle: nil)
		tblUserList.register(userListCellNib, forCellReuseIdentifier: UserListCell.identifier)
	}
	
	private func addInfinityScroll() {
		tblUserList.ins_addInfinityScroll(withHeight: 60) { [weak self] (scrollView) in
			guard let strongSelf = self else { return }
			if strongSelf.pageLoading {
				return
			}
			strongSelf.loadUserListPage(sinceUserId: strongSelf.lastSinceUserId, completion: { [weak scrollView] in
				guard let strongScrollView = scrollView else { return }
				strongScrollView.ins_endInfinityScroll(withStoppingContentOffset: true)
			})
		}
		let infinityIndicator = INSDefaultInfiniteIndicator.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 24))
		tblUserList.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator)
		infinityIndicator.startAnimating()
		
	}
	
	private func loadUserListPage(sinceUserId: Int?, completion: (() -> Void)?) {
		pageLoading = true
		apiManager.loadUserList(since: sinceUserId) { [weak self] (success, response, statusCode) in
			guard let strongSelf = self else { return }
			strongSelf.pageLoading = false
			if success,
				let response = response as? [[String: Any]] {
				strongSelf.tblUserList.beginUpdates()
				var newIndexPathList: [IndexPath] = []
				let userMapper = Mapper<User>()
				for userDic in response {
					if let user = userMapper.map(JSON: userDic) {
						newIndexPathList.append(IndexPath.init(row: strongSelf.userList.count, section: 0))
						strongSelf.userList.append(user)
						strongSelf.lastSinceUserId = user.id
					}
				}
				strongSelf.tblUserList.insertRows(at: newIndexPathList, with: .bottom)
				strongSelf.tblUserList.endUpdates()
				if newIndexPathList.count == 0 {
					strongSelf.tblUserList.ins_setInfinityScrollEnabled(false)
				}
			}
			else {
				strongSelf.handleErrorUserListResponse(success: success, response: response, statusCode: statusCode)
			}
			if let completion = completion {
				completion()
			}
		}
	}
	
	private func handleErrorUserListResponse(success: Bool, response: Any, statusCode: Int?){
		if let statusCode = statusCode {
			switch statusCode {
			case 403:
				break
				
			case 401:
				break
				
			default:
				break
			}
		}
	}
	
	private func addNextBarBtn() {
		let nextBarBtn = UIBarButtonItem.init(title: "Next", style: .done, target: self, action: #selector(didTouchNext))
		nextBarBtn.tintColor = UIColor.white
		nextBarBtn.isEnabled = false
		navigationItem.rightBarButtonItem = nextBarBtn
	}
	
	private func resetToInitialState() {
		clearSelectedList()
		
		for (index, _) in userList.enumerated() {
			if userList[index].isSelected {
				tableView(tblUserList, didSelectRowAt: IndexPath.init(row: index, section: 0))
			}
		}
	}
	
	// MARK: - overrided parent methods
	
	override func selectedUserListChanged(old: [User], new: [User]) {
		super.selectedUserListChanged(old: old, new: new)
		if let nextBarBtn = navigationItem.rightBarButtonItem {
			nextBarBtn.isEnabled = new.count > 0
		}
	}
	
	override func didTouchClose(forUserId id: Int) {
		if let userIndex = userList.index(where: { $0.id == id }) {
			tableView(tblUserList, didSelectRowAt: IndexPath.init(row: userIndex, section: 0))
		}
	}
	
	// MARK: - actions
	
	@objc func didTouchNext(_ sender: UIBarButtonItem) {
		let composeMessageVC = storyboard?.instantiateViewController(withIdentifier: "ComposeMessageViewController") as! ComposeMessageViewController
		composeMessageVC.selectedUserList = selectedUserList
		composeMessageVC.delegate = self
		navigationController?.pushViewController(composeMessageVC, animated: true)
	}
	
}

extension UserListViewController: UITableViewDataSource {
	
	// MARK: - UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return userList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: UserListCell.identifier, for: indexPath) as! UserListCell
		cell.configureCell(withUser: userList[indexPath.row])
		return cell
	}
	
}

extension UserListViewController: UITableViewDelegate {

	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 72
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		userList[indexPath.row].isSelected = !userList[indexPath.row].isSelected
		if let cell = tableView.cellForRow(at: indexPath) as? UserListCell {
			cell.updateCheckmarkIcon(isSelected: userList[indexPath.row].isSelected)
		}
		
		let user = userList[indexPath.row]
		user.isSelected ? selectUser(user) : removeUser(user)
	}

}


extension UserListViewController: ComposeMessageViewControllerDelegate {
	
	// MARK: - ComposeMessageViewControllerDelegate
	
	func didRemoveUser(withId id: Int){
		didTouchClose(forUserId: id)
	}
	
	func didTouchSendMessage(){
		navigationController?.popViewController(animated: true)
		resetToInitialState()
	}
}
