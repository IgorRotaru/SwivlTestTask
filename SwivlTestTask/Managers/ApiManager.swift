//
//  ApiManager.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/24/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit

final class ApiManager {
	
	typealias ApiCallback = (Bool, Any, HTTPURLResponse?) -> Void
	typealias SuccessCallback = (HTTPURLResponse?, Any) -> Void
	typealias FailureCallback = (HTTPURLResponse?, Any, Error?) -> Void
	
	// MARK: - Properties
	
	private var session: URLSession = URLSession.shared
	
	// MARK: - Public Methods
	
	func setupAccessToken(_ token: String) {
		let configuration = URLSession.shared.configuration
		let authHeaders = [
			"Authorization": "token \(token)"
		]
		configuration.httpAdditionalHeaders = authHeaders
		session = URLSession.init(configuration: configuration)
	}
	
	// MARK: - API Calls
	
	func loadUserList(since: Int?, callback: @escaping ApiCallback) {
		let sUrl = "https://api.github.com/users"
		guard let url = URL(string:sUrl) else {
			callback(false, [:], nil)
			return
		}
		
		var params: [String: Any] = ["per_page": Constants.userPerPage]
		if let since = since {
			params["since"] = since
		}
		
		runTask(withUrl: url, httpMethod: "GET", params: params, success: { (httpResponse, response) in
			DispatchQueue.main.async {
				callback(true, response, httpResponse)
			}
		}) { (httpResponse, response, error) in
			DispatchQueue.main.async {
				callback(false, response, httpResponse)
			}
		}
	}
	
	func authorizeUser(withParams params: [String: Any], callback: @escaping ApiCallback) {
		let sUrl = "https://github.com/login/oauth/access_token"
		guard let url = URL(string:sUrl) else {
			callback(false, [:], nil)
			return
		}
		let headers = ["cache-control": "no-cache", "content-type": "application/json", "Accept": "application/json"]
		
		runTask(withUrl: url, httpMethod: "POST", params: params, headers: headers, success: { (httpResponse, response) in
			DispatchQueue.main.async {
				callback(true, response, httpResponse)
			}
		}) { (httpResponse, response, error) in
			DispatchQueue.main.async {
				callback(false, response, httpResponse)
			}
		}
	}
	
	// MARK: - Private Methods
	
	private func runTask(withUrl url: URL, httpMethod: String, params: [String: Any]?, headers: [String: String]? = nil, success: @escaping(SuccessCallback), failure: @escaping(FailureCallback)) -> Void {
		
		let urlComp = NSURLComponents(string: url.absoluteString)!
		
		if let params = params {
			let items = params.toQueryItems()
			if !items.isEmpty {
				urlComp.queryItems = items
			}
		}
		
		var request: URLRequest = URLRequest(url: urlComp.url!)
		request.httpMethod = httpMethod
		request.allHTTPHeaderFields = headers != nil ? headers : Constants.defaultHeaders
		
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
