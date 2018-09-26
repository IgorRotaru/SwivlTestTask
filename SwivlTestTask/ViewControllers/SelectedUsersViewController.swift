//
//  SelectedUsersViewController.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/24/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

class SelectedUsersViewController: UIViewController {

	@IBOutlet weak var cvSelectedList: UICollectionView!
	@IBOutlet weak var lblNoUsers: UILabel!
	
	lazy var apiManager: ApiManager = {
		if let rootNavVC = self.navigationController as? RootNavigationController {
			return rootNavVC.apiManager
		}
		return ApiManager()
	}()
	
	var selectedUserList: [User] = [] {
		didSet{ selectedUserListChanged(old: oldValue, new: selectedUserList) }
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		cvSelectedList.dataSource = self
		cvSelectedList.delegate = self
		
		registerCells()
    }
	
	// MARK: - public
	
	func setSelectedUserList(_ list: [User]) {
		selectedUserList = list
		if let cvSelectedList = cvSelectedList {
			cvSelectedList.reloadData()
		}
	}
	
	func selectUser(_ user: User){
		let indexPath = IndexPath.init(row: selectedUserList.count, section: 0)
		selectedUserList.append(user)
		cvSelectedList.insertItems(at: [indexPath])
		scrollToLastCell()
	}
	
	func removeUser(_ user: User){
		if let userIndex = selectedUserList.index(where: { $0.id == user.id }) {
			let indexPath = IndexPath.init(row: userIndex, section: 0)
			selectedUserList.remove(at: userIndex)
			cvSelectedList.deleteItems(at: [indexPath])
		}
	}
	
	func clearSelectedList() {
		var indexPathList: [IndexPath] = []
		for (index, _) in selectedUserList.enumerated() {
			indexPathList.append(IndexPath.init(row: index, section: 0))
		}
		selectedUserList = []
		cvSelectedList.deleteItems(at: indexPathList)
	}
	
	// MARK: - private
	
	private func registerCells() {
		let selectedUserCellNib = UINib(nibName: SelectedUserCell.identifier, bundle: nil)
		cvSelectedList.register(selectedUserCellNib, forCellWithReuseIdentifier: SelectedUserCell.identifier)
	}
	
	private func scrollToLastCell() {
		if selectedUserList.count > 0 {
			cvSelectedList.scrollToItem(at: IndexPath.init(row: selectedUserList.count - 1, section: 0), at: .right, animated: true)
		}
	}
	
	func selectedUserListChanged(old: [User], new: [User]) {
		if view == nil {
			return
		}
		if old.count > 0,
			new.count == 0 {
			self.lblNoUsers.isHidden = false
			UIView.transition(with: lblNoUsers, duration: kAnimationDuration, options: .transitionCrossDissolve, animations: {
				self.lblNoUsers.alpha = 1.0
			}) { (finished) in
				
			}
		}
		else if old.count == 0,
			new.count > 0 {
			UIView.transition(with: lblNoUsers, duration: kAnimationDuration, options: .transitionCrossDissolve, animations: {
				self.lblNoUsers.alpha = 0.0
			}) { (finished) in
				self.lblNoUsers.isHidden = true
			}
		}
		else {
			lblNoUsers.isHidden = true
		}
	}

}

extension SelectedUsersViewController: UICollectionViewDataSource {

	// MARK: - UICollectionViewDataSource
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return selectedUserList.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUserCell.identifier, for: indexPath) as! SelectedUserCell
		cell.configureCell(withUser: selectedUserList[indexPath.row])
		cell.delegate = self
		return cell
	}
}

extension SelectedUsersViewController: UICollectionViewDelegateFlowLayout {
	
		// MARK: - SelectedUsersViewController
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize.init(width: 90, height: 110)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
}

extension SelectedUsersViewController: SelectedUserCellDelegate {
	
	// MARK: - SelectedUserCellDelegate
	
	func didTouchClose(forUserId id: Int) {
		if let userIndex = selectedUserList.index(where: { $0.id == id }) {
			let user = selectedUserList[userIndex]
			removeUser(user)
		}
	}
}
