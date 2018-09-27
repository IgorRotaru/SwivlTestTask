//
//  DictionaryExtension.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/26/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

extension Dictionary where Key == String {
	
	func toQueryItems() -> [URLQueryItem] {
		var items = [URLQueryItem]()
		for (key, value) in self {
			items.append(URLQueryItem(name: key, value: "\(value)"))
		}
		items = items.filter{ !$0.name.isEmpty }
		return items
	}
	
}
