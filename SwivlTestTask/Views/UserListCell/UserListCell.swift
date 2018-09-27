//
//  UserListCell.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit
import SDWebImage

final class UserListCell: UITableViewCell {

	// MARK: - IBOutlet
	
	@IBOutlet weak var avatarPreviewImageView: CircleImageView!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var profileLinkLabel: UILabel!
	@IBOutlet weak var checkmarkImageView: UIImageView!
	
	// MARK: - Lifecycle
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		selectionStyle = .none
    }
	
	// MARK: - Public Methods
	
	func configureCell(withUser user: User) {
		if let avatarPreviewLink = user.avatarPreview {
			avatarPreviewImageView.sd_setImage(with: URL(string: avatarPreviewLink), placeholderImage: UIImage(named: "noAvatar"))
		}
		else {
			avatarPreviewImageView.image = UIImage(named: "noAvatar")
		}
		userNameLabel.text = user.userName
		profileLinkLabel.text = user.profileLink
		checkmarkImageView.image = user.isSelected ? UIImage.init(named: "checkmarkOn") : UIImage.init(named: "checkmarkOff")
	}
	
	func updateCheckmarkIcon(isSelected: Bool) {
		UIView.transition(with: checkmarkImageView, duration: Constants.animationDuration, options: .transitionCrossDissolve, animations: {
			self.checkmarkImageView.image = isSelected ? UIImage.init(named: "checkmarkOn") : UIImage.init(named: "checkmarkOff")
		}) { (finished) in
			
		}
	}
}
