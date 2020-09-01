//
//  WebAuthController.swift
//  MUJ Buddy
//
//  Created by Nick on 5/16/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit
import WebKit

class WebAuthController: UIViewController {
    // Our web view
    lazy var webView: WKWebView = {
        let wview = WKWebView()
        wview.navigationDelegate = self
        return wview
    }()

    // The progress bar
    let pBar: UIProgressView = {
        let p = UIProgressView()
        p.tintColor = UIColor(named: "barTintColor")
        return p
    }()

    // Variable to control the login successful state
    private lazy var loginSuccessful: Bool = false

    let whitelistedURLs: [String] = [
        LOGIN_URL,
        CONF_URL,
    ]

    // Variables that will be set optionally by the instantiating VC
    var userID: String?
    var password: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Basic thingies
        navigationItem.title = "Login to DMS"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(handleCancel))
        view.backgroundColor = UIColor(named: "primaryLighter")

        // Configure the webview
        webView.load(URLRequest(url: URL(string: whitelistedURLs[0])!))

        // Add the views
        view.addSubview(pBar)
        view.addSubview(webView)

        // Add the constraints
        pBar.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, left: view.leftAnchor, height: 5)
        webView.anchorWithConstraints(top: pBar.bottomAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor)

        // Add observer for the webview progress
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    // MARK: - View did disappear

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // If login is not successful and still the view is being dismissed, means user has cancelled the login request
        if !loginSuccessful { NotificationCenter.default.post(name: .loginCancelled, object: nil, userInfo:["message": "Login action was cancelled by the user"]) }
    }

    // Handles the dismissal of the webview
    @objc fileprivate func handleCancel() {
        webView.removeFromSuperview()
        dismiss(animated: true)
    }
}

extension WebAuthController: WKNavigationDelegate {
    // Restrict navigation only to the DMS
    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let navigatedURL = navigationAction.request.url?.absoluteString {
            if whitelistedURLs.contains(navigatedURL) {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.cancel)
        }
    }

    // Keep the progress bar dancing
    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            pBar.progress = Float(webView.estimatedProgress)
        }
    }

    // Check if the login is successful
    // TODO: - Catch the success url in the navigation action to reduce login time
    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        guard let url = webView.url?.absoluteString else { return }

        if url == LOGIN_URL {
            // Fill in the userid automatically
            if let userid = userID {
                webView.evaluateJavaScript("document.getElementById('txtUserid').value = '\(userid)'", completionHandler: nil)
            }

            // Fill in the password automatically
            if let password = password {
                webView.evaluateJavaScript("document.getElementById('txtpassword').value = '\(password)'", completionHandler: nil)
            }

            // Special case; Use the bypass when the login limit has been exceeded
            webView.evaluateJavaScript("document.getElementById('labelerror').innerHTML === 'Your daily login attempt exceded'") { [weak self] res, _ in
                guard let result = res as? Int else { return }

                if result == 1 {
                    webView.load(URLRequest(url: URL(string: (self?.whitelistedURLs[1])!)!))
                }
            }
        }

        if url == CONF_URL {
            webView.getSessionID { [weak self] session in
                if session != "nil" {
                    DispatchQueue.main.async {
                        webView.removeFromSuperview()
                        self?.loginSuccessful = true
                        self?.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: .loginSuccessful, object: nil, userInfo: ["sessionID": session])
                        })
                    }
                }
            }
        }
    }
}

// My own extension to extract the sessionID out of the WKWebView
extension WKWebView {
    // Extension to extract the sessionID from the current session
    func getSessionID(completion: @escaping (String) -> Void) {
        let cookieJar = configuration.websiteDataStore.httpCookieStore

        cookieJar.getAllCookies { cookies in
            for cookie in cookies {
                if cookie.name == SESSION_COOKIE {
                    completion(cookie.value)
                    return
                }
            }
        }
    }
}
