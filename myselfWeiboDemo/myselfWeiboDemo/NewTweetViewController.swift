//
//  NewTweetViewController.swift
//  myselfWeiboDemo
//
//  Created by 傅中正 on 16/5/23.
//  Copyright © 2016年 Eric‘s Project. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController {

    var textView: UITextView?
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewTweetViewController.onKeyboardWillChangeFrame(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.lightGrayColor()
                
        let rightButton = UIBarButtonItem(title: "发送", style: .Plain, target: self, action: #selector(NewTweetViewController.sendNewTweet))
        self.navigationItem.rightBarButtonItem = rightButton
        
        textView = UITextView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height-64))
        textView?.backgroundColor = UIColor.whiteColor()
        textView?.font = UIFont.systemFontOfSize(16)
        self.view.addSubview(textView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendNewTweet() {
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String)!
        let text = textView?.text
        _ = WBHttpRequest(forShareAStatus: text, contatinsAPicture: nil, orPictureUrl: nil, withAccessToken: accessToken, andOtherProperties: nil, queue: nil) { (request, data, error) in
            if error != nil {
                print("###error###")
                print(error.code)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func onKeyboardWillChangeFrame(notification: NSNotification) {
        let dict = NSDictionary(dictionary: notification.userInfo!)
        let keyboardFrame = dict[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let duration = dict[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animateWithDuration(duration) {
            self.textView?.frame.size.height = self.view.bounds.height - (keyboardFrame?.height)!
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
