//
//  PictureViewController.swift
//  myselfWeiboDemo
//
//  Created by 傅中正 on 16/6/17.
//  Copyright © 2016年 Eric‘s Project. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var smallPic: UIImage?
    var pictureUrl: String?
    
    var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        self.view.userInteractionEnabled = true
        
        imageView = UIImageView(frame: self.view.bounds)
        imageView!.contentMode = .ScaleAspectFit
        imageView!.image = smallPic
        self.view.addSubview(imageView!)
        
        let onTap = UITapGestureRecognizer(target: self, action: #selector(PictureViewController.tap2Exit))
        self.view.addGestureRecognizer(onTap)
        onTap.numberOfTouchesRequired = 1; //手指数
        onTap.numberOfTapsRequired = 1; //tap次数
        onTap.delegate = self
        
        loadLargePic()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadLargePic() {
        print(pictureUrl)
        
        let largePic = pictureUrl?.stringByReplacingOccurrencesOfString("thumbnail", withString: "large", options: .LiteralSearch, range: nil)
        
        if pictureUrl != nil {
            let request = NSURLRequest(URL: NSURL(string: largePic!)!)
            let sessionImage = NSURLSession.sharedSession()
            let dataTaskImage = sessionImage.dataTaskWithRequest(request) { (data, response, error) in
                if error != nil
                {
                    print(error?.code)
                    print(error?.description)
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        if largePic?.hasSuffix(".gif") == true {
                            self.imageView!.image = UIImage.gifWithData(data!)
                        } else {
                            self.imageView!.image = UIImage(data: data!)
                        }
                    })
                }
            }
            dataTaskImage.resume()
        }
    }
    
    func tap2Exit() {
        self.dismissViewControllerAnimated(true, completion: nil)
//        self.navigationController?.popViewControllerAnimated(true)
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
