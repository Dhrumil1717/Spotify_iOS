//
//  AuthViewController.swift
//  Spotify
//
//  Created by Dhrumil Malaviya on 2021-03-01.

import UIKit
import WebKit  // apple provided framework for web views


class AuthViewController: UIViewController , WKNavigationDelegate
{
    private let webView : WKWebView = {
        
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true //allows rendering of javascript
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs//set of default preferences to use when rendering the page
        let webView = WKWebView(frame: .zero,configuration: config)
        
        return webView
    }()

    
    public var completionHandler:((Bool)->Void)? //use of closure
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self //navigation for webView
        view.addSubview(webView)
        guard let url = AuthManager.shared.signInUrl else {return} //run the url provided in authmanager
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        guard let url = webView.url else //getting the exact url
        {
            return
        }
        
        //Exchange the code for access token
        
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: {$0.name == "code"})?.value else { return }
        webView.isHidden = true
        
        AuthManager.shared.exchangeCodeForToken(code: code){
            [weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
        
    }
}
