//
//  SelectedUserCell.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit
import SDWebImage

@objc protocol SelectedUserCellDelegate: class {
	@objc optional func didTouchClose(forUserId id: Int)
}

class SelectedUserCell: UICollectionViewCell {

	@IBOutlet weak var btnRemove: UIButton!
	@IBOutlet weak var ivAvatarPreview: CircleImageView!
	@IBOutlet weak var lblUserName: UILabel!
	
	weak var delegate: SelectedUserCellDelegate?
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	// MARK: - public
	
	func configureCell(withUser user: User) {
		if let avatarPreviewLink = user.avatarPreview {
			ivAvatarPreview.sd_setImage(with: URL(string: avatarPreviewLink), placeholderImage: UIImage(named: "noAvatar"))
		}
		else {
			ivAvatarPreview.image = UIImage(named: "noAvatar")
		}
		lblUserName.text = user.userName
		btnRemove.tag = user.id ?? 0
	}

	// MARK: - actions
	
	@IBAction func didTouchRevomeUser(_ sender: UIButton) {
		if let didTouchClose = delegate?.didTouchClose(forUserId:) {
			didTouchClose(sender.tag)
		}
	}
	
}
