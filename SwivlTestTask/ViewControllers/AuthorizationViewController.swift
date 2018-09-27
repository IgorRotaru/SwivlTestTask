//
//  AuthorizationViewController.swift
//  SwivlTestTask
//
//  Created by Igor Rotaru on 9/26/18.
//  Copyright © 2018 Igor Rotaru. All rights reserved.
//

import UIKit
import WebKit

protocol AuthorizationViewControllerDelegate: class {
	func didReciveAuthorizationParams(_ params: [String: Any])
}

final class AuthorizationViewController: UIViewController {

	// MARK: - Properties
	
	weak var delegate: AuthorizationViewControllerDelegate?
	private var authorizationWebView: WKWebView!
	private var uuidState: String = NSUUID().uuidString
	
	// MARK: - Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Authorization"
		createWebView()
		redirectToGithubPage()
    }
	
	// MARK: - Private Methods
	
	private func redirectToGithubPage() {
		let sUrl = "https://github.com/login/oauth/authorize"
		guard let url = URL(string:sUrl) else {
			return
		}
		
		let params: [String: Any] = ["client_id": GithubCredentials.clientId,
									 "redirect_uri": GithubCredentials.redirectUrl,
									 "scope": "",
									 "state": uuidState]
		
		let headers = ["cache-control": "no-cache", "content-type": "application/json"]
		let urlComp = NSURLComponents(string: url.absoluteString)!
		let items = params.toQueryItems()
		if !items.isEmpty {
			urlComp.queryItems = items
		}
		
		var request: URLRequest = URLRequest(url: urlComp.url!)
		request.httpMethod = "GET"
		request.allHTTPHeaderFields = headers
		
		authorizationWebView.load(request)
	}
	
	
	private func createWebView(){
		let webConfiguration = WKWebViewConfiguration()
		authorizationWebView = WKWebView(frame: .zero, configuration: webConfiguration)
		authorizationWebView.navigationDelegate = self
		view = authorizationWebView
		authorizationWebView.clipsToBounds = true
	}

	private func handleUrl(_ urlRequest: URLRequest){
		if let url = urlRequest.url {
			if let params = url.queryParameters,
				let code = params["code"],
				url.absoluteString.lowercased().contains(GithubCredentials.redirectUrl.lowercased()),
				let state = params["state"],
				state == uuidState {
				
				let params: [String: Any] = ["client_id": GithubCredentials.clientId,
											 "client_secret": GithubCredentials.clientSecret,
											 "code": code]
				
				if let didReciveAuthorizationParams = delegate?.didReciveAuthorizationParams {
					didReciveAuthorizationParams(params)
				}
			}
		}
	}

	private func loadAuthPage(code: String) {
		
		let params: [String: Any] = ["client_id": GithubCredentials.clientId,
									 "client_secret": GithubCredentials.clientSecret,
									 "code": code]

		if let didReciveAuthorizationParams = delegate?.didReciveAuthorizationParams {
			didReciveAuthorizationParams(params)
		}
	}

}


extension AuthorizationViewController: WKNavigationDelegate {
	
	// MARK: WKNavigationDelegate
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		handleUrl(navigationAction.request)
		decisionHandler(.allow)
	}

}
