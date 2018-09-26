//
//  UserListCell.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit
import SDWebImage

class UserListCell: UITableViewCell {

	@IBOutlet weak var ivAvatarPreview: CircleImageView!
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblProfileLink: UILabel!
	@IBOutlet weak var ivCheckmark: UIImageView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
		lblProfileLink.text = user.profileLink
		ivCheckmark.image = user.isSelected ? UIImage.init(named: "checkmarkOn") : UIImage.init(named: "checkmarkOff")
	}
	
	func updateCheckmarkIcon(isSelected: Bool) {
		UIView.transition(with: ivCheckmark, duration: kAnimationDuration, options: .transitionCrossDissolve, animations: {
			self.ivCheckmark.image = isSelected ? UIImage.init(named: "checkmarkOn") : UIImage.init(named: "checkmarkOff")
		}) { (finished) in
			
		}
	}
}
