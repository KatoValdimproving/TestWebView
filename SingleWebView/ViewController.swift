//
//  ViewController.swift
//  SingleWebView
//
//  Created by user on 16/08/22.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var webView: WKWebView?
    var activityIndicatorView: UIActivityIndicatorView?
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add done button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        //Clean cookies and cache
        self.clean()
        
        //Connect to server
        //Instantiate and configure webView
        self.view.backgroundColor = UIColor.white
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.webView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView!)
        self.webView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.webView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.webView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.webView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.webView?.navigationDelegate = self
        
        //Instantiate and configure activityIndicator
        self.activityIndicatorView = UIActivityIndicatorView()
        self.activityIndicatorView?.style = .large
        self.activityIndicatorView?.color = UIColor.gray
        self.activityIndicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.activityIndicatorView!)
        self.activityIndicatorView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -200.0).isActive = true
        self.activityIndicatorView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        //Load AD request
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        let url = URL(string: "https://untrusted-root.badssl.com/")!
        webView?.load(URLRequest(url: url))
        webView?.allowsBackForwardNavigationGestures = true
    }
    
    @objc func done() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, cred)
      }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicatorView?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicatorView?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = false
    }
}
