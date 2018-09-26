//
//  ComposeMessageViewController.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/26/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

@objc protocol ComposeMessageViewControllerDelegate: class {
	@objc optional func didRemoveUser(withId id: Int)
	@objc optional func didTouchSendMessage()
}

class ComposeMessageViewController: SelectedUsersViewController {
	
	@IBOutlet weak var tvMessage: UITextView!
	@IBOutlet weak var btnSend: UIButton!
	@IBOutlet weak var scrollView: UIScrollView!
	
	weak var delegate: ComposeMessageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Compose Message"
		addKeyboardNotifications()
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - private
	
	private func addKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	private func updateBtnSendState() {
		btnSend.isEnabled = selectedUserList.count > 0 && tvMessage.text.count > 0
	}

	// MARK: - overrided parent methods
	
	override func selectedUserListChanged(old: [User], new: [User]) {
		super.selectedUserListChanged(old: old, new: new)
		updateBtnSendState()
	}
	
	override func didTouchClose(forUserId id: Int) {
		super.didTouchClose(forUserId: id)
		if let didRemoveUser = delegate?.didRemoveUser(withId:) {
			didRemoveUser(id)
		}
	}
	
	// MARK: - actions
	
	@IBAction func didTouchSend(_ sender: UIButton) {
		if let didTouchSendMessage = delegate?.didTouchSendMessage {
			didTouchSendMessage()
		}
	}
	
	@IBAction func didTapView(_ sender: Any) {
		if tvMessage.isFirstResponder {
			tvMessage.resignFirstResponder()
		}
	}
	
	
	// MARK: - notifications
	
	@objc func keyboardWillShow(notification: NSNotification) {
		var userInfo = notification.userInfo!
		var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		var endKeyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = view.convert(keyboardFrame, from: nil)
		endKeyboardFrame = view.convert(endKeyboardFrame, from: nil)
		
		var contentInset = scrollView.contentInset
		contentInset.bottom = endKeyboardFrame.size.height
		scrollView.contentInset = contentInset
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
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
