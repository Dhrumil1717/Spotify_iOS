//
//  WelcomeViewController.swift
//  Spotify
//
//  Created by Dhrumil Malaviya on 2021-03-01.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let signInButton:UIButton =
    {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Spotify"
        view.backgroundColor = .systemGreen
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() //provide the location of button on the screen
    {
        super.viewDidLayoutSubviews()
        signInButton.frame = CGRect(x: 20,
                                    y: view.height-50-view.safeAreaInsets.bottom,
                                    width: view.width-50,
                                    height: 50)
    }
    
    @objc func didTapSignIn()
    {
        let vc = AuthViewController()
        vc.completionHandler = {successful in DispatchQueue.main.async //connecting it with completion handler made in authview controller
            {
                self.handleSignIn(success:successful)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(vc, animated: true)
    }
    private func handleSignIn(success:Bool)
    {
        guard success else {
            let alert = UIAlertController(title: "Oops", message: "Something Went Wrong", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            return}
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC,animated: true)
    }
}
