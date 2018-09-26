//
//  CircleImageView.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {

	override func layoutSubviews() {
		super.layoutSubviews()
		layer.masksToBounds = true
		layer.cornerRadius = frame.size.height/2.0
	}
	
	override var bounds: CGRect {
		didSet {
			layer.masksToBounds = true
			layer.cornerRadius = bounds.size.height/2.0
		}
	}

}
