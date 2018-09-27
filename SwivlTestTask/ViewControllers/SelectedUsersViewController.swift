//
//  SelectedUsersViewController.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/24/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

final class SelectedUsersViewController: UIViewController {

	// MARK: - IBOutlet
	
	@IBOutlet weak private var selectedUsersCollectionView: UICollectionView!
	@IBOutlet weak private var noUsersLabel: UILabel!
	
	// MARK: - Properties
	
	weak var delegate: SelectedUserCellDelegate?
	var selectedUserList: [User] = [] {
		didSet{ selectedUserListChanged(old: oldValue, new: selectedUserList) }
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		registerCells()
    }
	
	// MARK: - Public Methods
	
	func setSelectedUserList(_ list: [User]) {
		selectedUserList = list
		if let cvSelectedList = selectedUsersCollectionView {
			cvSelectedList.reloadData()
		}
	}
	
	func selectUser(_ user: User){
		let indexPath = IndexPath.init(row: selectedUserList.count, section: 0)
		selectedUserList.append(user)
		selectedUsersCollectionView.insertItems(at: [indexPath])
		scrollToLastCell()
	}
	
	func removeUser(_ user: User){
		if let userIndex = selectedUserList.index(where: { $0.id == user.id }) {
			let indexPath = IndexPath.init(row: userIndex, section: 0)
			selectedUserList.remove(at: userIndex)
			selectedUsersCollectionView.deleteItems(at: [indexPath])
		}
	}
	
	func clearSelectedList() {
		let indexPathList = [Int](0 ..< selectedUserList.count).reduce([], { $0 + [IndexPath(row: $1, section: 0)] })
		selectedUserList = []
		selectedUsersCollectionView.deleteItems(at: indexPathList)
	}
	
	// MARK: - Private Methods
	
	private func registerCells() {
		let selectedUserCellNib = UINib(nibName: SelectedUserCell.identifier, bundle: nil)
		selectedUsersCollectionView.register(selectedUserCellNib, forCellWithReuseIdentifier: SelectedUserCell.identifier)
	}
	
	private func scrollToLastCell() {
		if selectedUserList.count > 0 {
			selectedUsersCollectionView.scrollToItem(at: IndexPath.init(row: selectedUserList.count - 1, section: 0), at: .right, animated: true)
		}
	}
	
	private func selectedUserListChanged(old: [User], new: [User]) {
		if view == nil {
			return
		}
		if old.count > 0,
			new.count == 0 {
			self.noUsersLabel.isHidden = false
			UIView.transition(with: noUsersLabel, duration: Constants.animationDuration, options: .transitionCrossDissolve, animations: {
				self.noUsersLabel.alpha = 1.0
			}) { (finished) in
				
			}
		}
		else if old.count == 0,
			new.count > 0 {
			UIView.transition(with: noUsersLabel, duration: Constants.animationDuration, options: .transitionCrossDissolve, animations: {
				self.noUsersLabel.alpha = 0.0
			}) { (finished) in
				self.noUsersLabel.isHidden = true
			}
		}
		else {
			noUsersLabel.isHidden = true
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
		cell.delegate = delegate
		return cell
	}
}

extension SelectedUsersViewController: UICollectionViewDelegateFlowLayout {
	
	// MARK: - SelectedUsersViewController
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize.init(width: 90, height: collectionView.frame.size.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
}
