//
//  User.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/25/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit
import ObjectMapper

struct User: Mappable {
	var id: Int?
	var userName: String?
	var avatarPreview: String?
	var profileLink: String?
	var isSelected = false
	
	init?(map: Map) {
		
	}
	
	mutating func mapping(map: Map) {
		id 				<- map["id"]
		userName 		<- map["login"]
		avatarPreview 	<- map["avatar_url"]
		profileLink		<- map["url"]
	}
	
}
