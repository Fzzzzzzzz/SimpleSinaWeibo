//
//  AppDelegate.swift
//  myselfWeiboDemo
//
//  Created by 傅中正 on 16/4/26.
//  Copyright © 2016年 Eric‘s Project. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate, WeiboSDKDelegate, WBHttpRequestDelegate {

    var window: UIWindow?

    let appKey = "1807629885"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(appKey)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        
        let _userDefault = NSUserDefaults.standardUserDefaults()
        let loginState = _userDefault.objectForKey("loginState")
        if loginState?.string == "true" {
            let tabbar = UITabBarController()
            UITabBar.appearance().tintColor = UIColor.redColor()
            tabbar.hidesBottomBarWhenPushed = true
            tabbar.delegate = self
            
            let navi_1 = UINavigationController(rootViewController: HomeViewController())
            navi_1.title = "首页"
            
            let navi_2 = UINavigationController(rootViewController: MessageViewController())
            navi_2.title = "消息"
            
            tabbar.viewControllers = [navi_1, navi_2]
            tabbar.selectedIndex = 0
            
            self.window?.rootViewController = tabbar
        } else {
            _userDefault.setObject("false", forKey: "loginState")
            self.window?.rootViewController = LoginViewController()
        }
        self.window?.makeKeyAndVisible()

        return true
    }
    
    func login() {
        print("login>>>")
        let redirectURI = "https://api.weibo.com/oauth2/default.html"
        let request = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = redirectURI
        request.scope = "all"
        WeiboSDK.sendRequest(request)
    }
    
    
    
    func revokeoAuth() {
        let accessToken: String? = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String
        print(accessToken)
        if accessToken == nil {
            return
        }
        
        WeiboSDK.logOutWithToken(accessToken!, delegate: self, withTag: "loginOut")
    }
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        if (request.isKindOfClass(WBProvideMessageForWeiboRequest)) {
            print("didReceiveWeiboRequest")
        }
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        print("didReceiveWeiboResponse")
        if (response.isKindOfClass(WBAuthorizeResponse)) {
            _ = "响应状态: \(response.statusCode.rawValue)\nresponse.userId: \((response as! WBAuthorizeResponse).userID)\nresponse.accessToken: \((response as! WBAuthorizeResponse).accessToken)\n响应UserInfo数据: \(response.userInfo)\n原请求UserInfo数据: \(response.requestUserInfo)"
            
            if response.statusCode.rawValue == 0 {
                print("in appdelegate 授权成功")
                let userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setObject((response as! WBAuthorizeResponse).accessToken, forKey: "accessToken")
                userDefault.setObject((response as! WBAuthorizeResponse).refreshToken, forKey: "refreshToken")
                userDefault.setObject("true", forKey: "loginState")
                let delayInSeconds = 0.5
                let popTime = dispatch_time(dispatch_time_t(delayInSeconds), Int64(NSEC_PER_SEC))
                dispatch_after(popTime, dispatch_get_main_queue()) {
                (self.window?.rootViewController as! LoginViewController).trans2HomePage()
                }
            }
        }
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self)
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

