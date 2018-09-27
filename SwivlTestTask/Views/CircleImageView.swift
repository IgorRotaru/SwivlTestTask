//
//  CircleImageView.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

final class CircleImageView: UIImageView {
	
	// MARK: - Overridden Properties
	
	override var bounds: CGRect {
		didSet {
			configureView()
		}
	}

	// MARK: - Overridden Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		configureView()
	}
	
	// MARK: - Private Methods
	
	private func configureView() {
		layer.cornerRadius = frame.size.height / 2.0
		layer.masksToBounds = true
	}

}
