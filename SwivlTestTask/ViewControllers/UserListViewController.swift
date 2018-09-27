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

final class UserListViewController: UIViewController {

	// MARK: - IBOutlet
	
	@IBOutlet weak private var userTableView: UITableView!
	
	// MARK: - Properties
	
	var apiManager: ApiManager?
	
	lazy private var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter.init()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return dateFormatter
	}()

	private var lastSinceUserId: Int?
	private var pageLoading: Bool = false
	private var userList: [User] = []
	private var selectedUsersViewController: SelectedUsersViewController!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Select Users"
		setupStatusBar(statusBarBgView: AppUtility.statusBarBgView)
		registerCells()
		addInfinityScroll()
		addNextBarBtn()
		loadUserListPage(sinceUserId: lastSinceUserId, completion: nil)
	}

	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination as? SelectedUsersViewController,
			segue.identifier == SegueIdentifier.fromUserListToSelectedUsers {
			selectedUsersViewController = destinationVC
			selectedUsersViewController.delegate = self
		}
		else if let composeMessageVC = segue.destination as? ComposeMessageViewController,
			segue.identifier == SegueIdentifier.toComposeMessage {
			composeMessageVC.delegate = self
		}
		else if let authorizationVC = segue.destination as? AuthorizationViewController,
			segue.identifier == SegueIdentifier.toAuthorization {
			authorizationVC.delegate = self
		}
	}
	
	// MARK: - Private Methods
	
	private func registerCells() {
		let userListCellNib = UINib(nibName: UserListCell.identifier, bundle: nil)
		userTableView.register(userListCellNib, forCellReuseIdentifier: UserListCell.identifier)
	}
	
	private func addInfinityScroll() {
		userTableView.ins_addInfinityScroll(withHeight: 60) { [weak self] (scrollView) in
			guard let strongSelf = self else { return }
			if strongSelf.pageLoading {
				return
			}
			strongSelf.loadUserListPage(sinceUserId: strongSelf.lastSinceUserId, completion: { [weak scrollView] in
				guard let strongScrollView = scrollView else { return }
				strongScrollView.ins_endInfinityScroll(withStoppingContentOffset: true)
			})
		}
		let infinityIndicator = INSDefaultInfiniteIndicator.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
		userTableView.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator)
		infinityIndicator.startAnimating()
		
	}
	
	private func loadUserListPage(sinceUserId: Int?, completion: (() -> Void)?) {
		pageLoading = true
		apiManager?.loadUserList(since: sinceUserId) { [weak self] (success, response, httpResponse) in
			guard let strongSelf = self else { return }
			strongSelf.pageLoading = false
			if success,
				let response = response as? [[String: Any]] {
				strongSelf.userTableView.beginUpdates()
				var newIndexPathList: [IndexPath] = []
				let userMapper = Mapper<User>()
				for userDic in response {
					if let user = userMapper.map(JSON: userDic) {
						newIndexPathList.append(IndexPath.init(row: strongSelf.userList.count, section: 0))
						strongSelf.userList.append(user)
						strongSelf.lastSinceUserId = user.id
					}
				}
				strongSelf.userTableView.insertRows(at: newIndexPathList, with: .bottom)
				strongSelf.userTableView.endUpdates()
				if newIndexPathList.count == 0 {
					strongSelf.userTableView.ins_setInfinityScrollEnabled(false)
				}
			}
			else {
				strongSelf.handleErrorUserListResponse(success: success, response: response, httpResponse: httpResponse)
			}
			if let completion = completion {
				completion()
			}
		}
	}
	
	private func handleErrorUserListResponse(success: Bool, response: Any, httpResponse: HTTPURLResponse?){
		if let httpResponse = httpResponse {
			switch httpResponse.statusCode {
			case 403:
				if let remainingRateLimit = httpResponse.allHeaderFields["X-RateLimit-Remaining"] as? String,
					Int(remainingRateLimit) == 0,
				let resetRateLimit = httpResponse.allHeaderFields["X-RateLimit-Reset"] as? String {
					let resetDate = Date.init(timeIntervalSince1970: TimeInterval(resetRateLimit) ?? 0)
					presentRateLimitAlert(message: "API rate limit exceeded for current ip, you can authorize with github to continue or wait to \(dateFormatter.string(from: resetDate))")
				}
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
		selectedUsersViewController.clearSelectedList()
		
		for (index, user) in userList.enumerated() {
			if user.isSelected {
				tableView(userTableView, didSelectRowAt: IndexPath.init(row: index, section: 0))
			}
		}
	}
	
	private func presentRateLimitAlert(message: String) {
		let rateLimitAlert = UIAlertController.init(title: "", message: message, preferredStyle: .alert)
		
		let okAction = UIAlertAction.init(title: "OK", style: .default) { [weak self](action) in
			guard let strongSelf = self else{
				return
			}
			strongSelf.dismiss(animated: true, completion: nil)
			strongSelf.showGithubAuthorization()
		}
		rateLimitAlert.addAction(okAction)
		
		let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { [weak self](action) in
			guard let strongSelf = self else{
				return
			}
			strongSelf.dismiss(animated: true, completion: nil)
		}
		rateLimitAlert.addAction(cancelAction)
		
		present(rateLimitAlert, animated: true, completion: nil)
	}
	
	private func presentAlertMessage(_ message: String) {
		let authorizationFailedAlert = UIAlertController.init(title: "", message: message, preferredStyle: .alert)

		let cancelAction = UIAlertAction.init(title: "OK", style: .cancel) { [weak self](action) in
			guard let strongSelf = self else{
				return
			}
			strongSelf.dismiss(animated: true, completion: nil)
		}
		authorizationFailedAlert.addAction(cancelAction)
		
		present(authorizationFailedAlert, animated: true, completion: nil)
	}
	
	private func showGithubAuthorization() {
		performSegue(withIdentifier: SegueIdentifier.toAuthorization, sender: nil)
	}
	
	private func updateNextButton() {
		if let nextBarBtn = navigationItem.rightBarButtonItem {
			nextBarBtn.isEnabled = selectedUsersViewController.selectedUserList.count > 0
		}
	}
	
	// MARK: - Actions
	
	@objc private func didTouchNext(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: SegueIdentifier.toComposeMessage, sender: nil)
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
		user.isSelected ? selectedUsersViewController.selectUser(user) : selectedUsersViewController.removeUser(user)
		updateNextButton()
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
	
	func selectedUserList() -> [User] {
		return selectedUsersViewController.selectedUserList
	}
}

extension UserListViewController: AuthorizationViewControllerDelegate {
	
	// MARK: - AuthorizationViewControllerDelegate
	
	func didReciveAuthorizationParams(_ params: [String: Any]) {
		navigationController?.popViewController(animated: true)
		apiManager?.authorizeUser(withParams: params) { [weak self] (success, response, httpResponse) in
			guard let strongSelf = self else { return }
			if success,
				let response = response as? [String: Any],
				let accessToken = response["access_token"] as? String {
				strongSelf.apiManager?.setupAccessToken(accessToken)
				strongSelf.loadUserListPage(sinceUserId: strongSelf.lastSinceUserId, completion: nil)
			}
			else {
				strongSelf.presentAlertMessage("Authorization failed")
			}
		}
	}
}

extension UserListViewController: SelectedUserCellDelegate {

	// MARK: - SelectedUserCellDelegate

	 func didTouchClose(forUserId id: Int) {
		if let userIndex = userList.index(where: { $0.id == id }) {
			tableView(userTableView, didSelectRowAt: IndexPath.init(row: userIndex, section: 0))
		}
	}
}
