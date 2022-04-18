//
//  DJLoginViewController.swift
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

import UIKit

typealias VoidBlock = () -> Void

class DJLoginViewController: UIViewController {
    
    @objc var loginSuccessBlock: VoidBlock?
    
    var loginButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "登录"

        loginButton.backgroundColor = .lightGray
        loginButton.bounds = .init(x: 0, y: 0, width: 100, height: 100)
        loginButton.setTitle("登录", for: .normal)
        loginButton.center = view.center
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        view.addSubview(loginButton)

    }
    

    @objc func loginAction() {
        NSLog("登录成功")
        if (loginSuccessBlock != nil) {
            loginSuccessBlock!()
        }
        self .dismiss(animated: true, completion: nil)
        
    }

}
