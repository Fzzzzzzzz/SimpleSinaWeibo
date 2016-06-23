//
//  MessageViewController.swift
//  myselfWeiboDemo
//
//  Created by 傅中正 on 16/4/28.
//  Copyright © 2016年 Eric‘s Project. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "消息"
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let indexOfPage = scrollView.contentOffset.x / self.view.bounds.width
        switch indexOfPage {
        case 0:
            self.title = "首页"//HomeViewController().title
        case 1:
            self.title = "热门"//HomeViewController().title
        default:
            break
        }
        print(self.title)
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
