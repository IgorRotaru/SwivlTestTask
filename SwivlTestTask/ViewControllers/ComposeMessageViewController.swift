//
//  ComposeMessageViewController.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/26/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

protocol ComposeMessageViewControllerDelegate: class {
	func didRemoveUser(withId id: Int)
	func didTouchSendMessage()
	func selectedUserList() -> [User]
}

final class ComposeMessageViewController: UIViewController {
	
	// MARK: - IBOutlet
	
	@IBOutlet weak private var messageTextView: UITextView!
	@IBOutlet weak private var sendButton: UIButton!
	@IBOutlet weak private var scrollView: UIScrollView!
	
	// MARK: - Properties
	
	weak var delegate: ComposeMessageViewControllerDelegate?
	private var selectedUsersViewController: SelectedUsersViewController!

	// MARK: - Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Compose Message"
		addKeyboardNotifications()
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination as? SelectedUsersViewController,
			segue.identifier == SegueIdentifier.fromComposeMessageToSelectedUsers {
			selectedUsersViewController = destinationVC
			selectedUsersViewController.delegate = self
			if let delegate = delegate {
				selectedUsersViewController.setSelectedUserList(delegate.selectedUserList())
			}
		}
	}
	
	// MARK: - Private Methods
	
	private func addKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	private func updateBtnSendState() {
		let messageCond = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
		let usersCond = selectedUsersViewController.selectedUserList.count > 0

		sendButton.isEnabled = usersCond && messageCond
	}
	
	// MARK: - IBActions
	
	@IBAction private func didTouchSend(_ sender: UIButton) {
		delegate?.didTouchSendMessage()
	}
	
	@IBAction private func didTapView(_ sender: Any) {
		if messageTextView.isFirstResponder {
			messageTextView.resignFirstResponder()
		}
	}
	
	// MARK: - notifications
	
	@objc private func keyboardWillShow(notification: NSNotification) {
		var userInfo = notification.userInfo!
		var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		var endKeyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = view.convert(keyboardFrame, from: nil)
		endKeyboardFrame = view.convert(endKeyboardFrame, from: nil)
		
		var contentInset = scrollView.contentInset
		contentInset.bottom = endKeyboardFrame.size.height
		scrollView.contentInset = contentInset
	}
	
	@objc private func keyboardWillHide(notification: NSNotification) {
		var contentInset = scrollView.contentInset
		contentInset.bottom = 0
		scrollView.contentInset = contentInset
	}
}

extension ComposeMessageViewController: UITextViewDelegate {
	
	// MARK: - UITextViewDelegate
	
	func textViewDidChange(_ textView: UITextView) {
		updateBtnSendState()
	}
	
}

extension ComposeMessageViewController: SelectedUserCellDelegate {
	
	// MARK: - SelectedUserCellDelegate
	
	func didTouchClose(forUserId id: Int) {
		if let userIndex = selectedUsersViewController.selectedUserList.index(where: { $0.id == id }) {
			selectedUsersViewController.removeUser(selectedUsersViewController.selectedUserList[userIndex])
		}
		delegate?.didRemoveUser(withId: id)
		updateBtnSendState()
	}
}
