//
//  SelectedUserCell.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit
import SDWebImage

protocol SelectedUserCellDelegate: class {
	 func didTouchClose(forUserId id: Int)
}

final class SelectedUserCell: UICollectionViewCell {

	// MARK: - IBOutlet
	
	@IBOutlet weak var removeButton: UIButton!
	@IBOutlet weak var avatarPreviewImageView: CircleImageView!
	@IBOutlet weak var userNameLabel: UILabel!
	
	weak var delegate: SelectedUserCellDelegate?
	
	// MARK: - public
	
	func configureCell(withUser user: User) {
		if let avatarPreviewLink = user.avatarPreview {
			avatarPreviewImageView.sd_setImage(with: URL(string: avatarPreviewLink), placeholderImage: UIImage(named: "noAvatar"))
		}
		else {
			avatarPreviewImageView.image = UIImage(named: "noAvatar")
		}
		userNameLabel.text = user.userName
		removeButton.tag = user.id ?? 0
	}

	// MARK: - IBActions
	
	@IBAction private func didTouchRevomeUser(_ sender: UIButton) {
		delegate?.didTouchClose(forUserId: sender.tag)
	}
	
}
