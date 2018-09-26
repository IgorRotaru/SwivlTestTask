//
//  ViewExtension.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

extension UIView {

	open class var identifier: String {
		get {
			return String(describing: self)
		}
	}
	
}
