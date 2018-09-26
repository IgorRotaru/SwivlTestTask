//
//  UIViewControllerExtension.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

extension UIViewController {
	
	func setupStatusBar(statusBarBgView: UIView) {
		let navigationBar = navigationController?.navigationBar
		UIApplication.shared.keyWindow!.insertSubview(statusBarBgView, aboveSubview: navigationBar!)
	}
	
}
