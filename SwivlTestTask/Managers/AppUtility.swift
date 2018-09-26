//
//  AppUtility.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

let kUserPerPage: Int = 30
let kAnimationDuration: Double = 0.3

struct AppUtility {
	
	static var statusBarBgView = { () -> UIView in
		let statusBarBgView = UIView(frame: UIApplication.shared.statusBarFrame)
		statusBarBgView.backgroundColor = .white
		return statusBarBgView
	}()
	
}
