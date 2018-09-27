//
//  URLExtension.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/26/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

extension URL {
	
	public var queryParameters: [String: String]? {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
			return nil
		}
		
		var parameters = [String: String]()
		for item in queryItems {
			parameters[item.name] = item.value
		}
		
		return parameters
	}
}
