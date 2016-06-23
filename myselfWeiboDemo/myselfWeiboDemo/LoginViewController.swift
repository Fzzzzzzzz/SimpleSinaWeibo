//
//  LoginViewController.swift
//  myselfWeiboDemo
//
//  Created by 傅中正 on 16/6/21.
//  Copyright © 2016年 Eric‘s Project. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var accessToken: String? = nil
    var refreshToken: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        self.view.backgroundColor = UIColor.whiteColor()

        let loginButton = UIButton(frame: CGRectMake(50, 150, 100, 40))
        loginButton.backgroundColor = UIColor.blueColor()
        loginButton.titleLabel?.text = "微博帐号登录"
        loginButton.setTitle("微博帐号登录", forState: .Normal)
        loginButton.addTarget(self, action: #selector(LoginViewController.trans2Login), forControlEvents: .TouchUpInside)
        self.view.addSubview(loginButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func trans2Login() {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate?.login()
    }
    
    func trans2HomePage() {
        print("trans2HomePage")
        
//        let delayInSeconds = 0.5
//        let popTime = dispatch_time(dispatch_time_t(delayInSeconds), Int64(NSEC_PER_SEC))
//        dispatch_after(popTime, dispatch_get_main_queue()) {
            print("跳转。。。")
            let tabbar = UITabBarController()
            UITabBar.appearance().tintColor = UIColor.redColor()
            tabbar.hidesBottomBarWhenPushed = true
            
            let navi_1 = UINavigationController(rootViewController: HomeViewController())
            navi_1.title = "首页"
            
            let navi_2 = UINavigationController(rootViewController: MessageViewController())
            navi_2.title = "消息"
            
            tabbar.viewControllers = [navi_1, navi_2]
            tabbar.selectedIndex = 0
            
            self.presentViewController(tabbar, animated: false, completion: nil)
//        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
