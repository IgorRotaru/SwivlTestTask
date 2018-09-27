//
//  AppUtility.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

struct AppUtility {
	
	static var statusBarBgView = { () -> UIView in
		let statusBarBgView = UIView(frame: UIApplication.shared.statusBarFrame)
		statusBarBgView.backgroundColor = .white
		return statusBarBgView
	}()
	
}

enum Constants {
	static let userPerPage = 30
	static let animationDuration = 0.3
	static let defaultHeaders = ["cache-control": "no-cache", "content-type": "application/json"]
}

enum GithubCredentials {
	static let clientId = "d46a5e015b06fbce4fe2"
	static let clientSecret = "2f8dbf8d1644f13bad9af2c01310f7e393d790f3"
	static let redirectUrl = "com.iv.testapp://callback"
}

enum SegueIdentifier {
	static let toComposeMessage = "ComposeMessageSegue"
	static let fromUserListToSelectedUsers = "UserListToSelectedUsersSegue"
	static let fromComposeMessageToSelectedUsers = "ComposeMessageToSelectedUsersSegue"
	static let toAuthorization = "AuthorizationSegue"
}
