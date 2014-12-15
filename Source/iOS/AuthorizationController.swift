//
//  AuthorizationController.swift
//  Wunderlist
//
//  Created by Constantine Fry on 04/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

protocol AuthorizationControllerDelegate: class {
    func authorizationControllerUserDidCancel(controller: AuthorizationController)
    func authorizationController(controller: AuthorizationController, didReachRedirectURL redirectURL: NSURL)
}

class AuthorizationController: UIViewController, UIWebViewDelegate {
    /** The URL to page where user can enter his credentials. */
    private let authorizationURL    : NSURL
    
    /** When web view reaches this URL it calls delegate. */
    private let redirectURL         : NSURL
    
    /** The delegate. */
    weak var delegate               : AuthorizationControllerDelegate?
    
    /** The web view to load `authorizationURL`. */
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    init(authorizationURL: NSURL, redirectURL: NSURL, delegate: AuthorizationControllerDelegate) {
        self.authorizationURL = authorizationURL
        self.redirectURL = redirectURL
        self.delegate = delegate
        super.init(nibName: "WunderlistAuthorizationController", bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.showsVerticalScrollIndicator = false
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelButtonTapped"))
        navigationItem.leftBarButtonItem = cancelButton
        loadAuthorizationPage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        webView.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    func loadAuthorizationPage() {
        let request = NSURLRequest(URL: authorizationURL)
        webView.loadRequest(request)
    }
    
    @objc func cancelButtonTapped() {
        delegate?.authorizationControllerUserDidCancel(self)
    }
    
    // MARK: - Web view delegate methods
    
    /** If we have reached redirect URL we pass that URL to delegate. */
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let URLString = request.URL.absoluteString {
            if URLString.hasPrefix(redirectURL.absoluteString!) {
                // If we've reached redirect URL we should let know delegate.
                delegate?.authorizationController(self, didReachRedirectURL: request.URL)
                return false
            }
        }
        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        if webView.alpha == 0 {
            showWebViewAnimated()
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webView.alpha == 0 {
            showWebViewAnimated()
        }
    }
    
    func showWebViewAnimated() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.webView.alpha = 1
            self.activityIndicator.alpha = 0
        }) { (result) -> Void in
            self.activityIndicator.startAnimating()
        }
    }
    
}
