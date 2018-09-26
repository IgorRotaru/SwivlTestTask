//
//  ApiManager.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/24/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

typealias ApiCallback = (Bool, Any, Int?) -> Void
typealias SuccessCallback = (HTTPURLResponse?, Any) -> Void
typealias FailureCallback = (HTTPURLResponse?, Any, Error?) -> Void

class ApiManager {
	
	private var session: URLSession = URLSession.shared
	
	// MARK: - api calls
	
	func loadUserList(since: Int?, callback: @escaping ApiCallback) {
		let sUrl:String = "https://api.github.com/users"
		guard let url: URL = URL(string:sUrl) else {
			callback(false, [:], nil)
			return
		}
		
		var params: [String: Any] = ["per_page": kUserPerPage]
		if let since = since {
			params["since"] = since
		}
		NSLog("\(params)")
		GET(url: url, params: params, success: { (httpResponse, response) in
			DispatchQueue.main.async {
				callback(true, response, httpResponse?.statusCode)
			}
		}) { (httpResponse, response, error) in
			DispatchQueue.main.async {
				callback(false, response, httpResponse?.statusCode)
			}
		}
	}
	
	// MARK: private
	
	
	private func GET(url: URL, params: [String: Any]?, success: @escaping(SuccessCallback), failure: @escaping(FailureCallback)) -> Void {
		
		let headers = ["cache-control": "no-cache", "content-type": "application/json"]
		let urlComp = NSURLComponents(string: url.absoluteString)!
		var items = [URLQueryItem]()
		if let params = params {
			for (key, value) in params {
				items.append(URLQueryItem(name: key, value: "\(value)"))
			}
			items = items.filter{ !$0.name.isEmpty }
			
			if !items.isEmpty {
				urlComp.queryItems = items
			}
		}
		
		var request: URLRequest = URLRequest(url: urlComp.url!)
		request.httpMethod = "GET"
		request.allHTTPHeaderFields = headers
		
		_ = runTask(withRequest: request, success: success, failure: failure)
	}

	private func runTask(withRequest request: URLRequest, success: @escaping(SuccessCallback), failure: @escaping (FailureCallback)) -> URLSessionDataTask? {
		
		let task = session.dataTask(with: request) { (data, response, error) in
			var result: Any = [:]
			if let data = data {
				if(data.count > 0){
					var response: Any = [:]
					do {
						let json = try JSONSerialization.jsonObject(with: data, options: [])
						response = json
					}
					catch {}
					if let json = response as? [String: Any] {
						result = json
					}
					else if let array = response as? [[String: Any]] {
						result = array
					}
				}
			}
			guard let httpResponse = response as? HTTPURLResponse else {
				failure(nil, result, error)
				return
			}
			if error != nil {
				failure(httpResponse, result, error)
				return
			}
//			NSLog("\(request.httpMethod ?? "httpMethod"): \(result)")
			
			if(httpResponse.statusCode >= 200 && httpResponse.statusCode <= 204) {
				success(httpResponse, result)
			}
			else {
				failure(httpResponse, result, error)
			}
		}
		task.resume()
		return task
	}
	
	
}
