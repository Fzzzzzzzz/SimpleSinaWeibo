//
//  commentInfoViewController.swift
//  myselfWeiboDemo
//
//  Created by 傅中正 on 16/5/10.
//  Copyright © 2016年 Eric‘s Project. All rights reserved.
//

import UIKit

class commentInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WBHttpRequestDelegate, UITextViewDelegate, LinkLabelInteractionDelegate {

    var _tableView: UITableView?
    var commentDataSource = [weiboCommentItem]()
    var weiboInfo = weiboInfoItem()
    var page = 1
    var totalNumber = 0
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = ""

        // Do any additional setup after loading the view.
        _tableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height-64), style: .Plain)
        _tableView?.delegate = self
        _tableView?.dataSource = self
        self.view.addSubview(_tableView!)
        
        self.loadCommentsDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (commentDataSource.count+1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let weiboInfoCellId = "weiboInfoCell"
        let commentCellId = "commentCell"
        var cell: UITableViewCell?

        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(weiboInfoCellId)
            if cell == nil {
                cell = createCell(1, reuseIdentifier: weiboInfoCellId)
            }
            
            if weiboInfo.avastar_large_data == nil {
                let request = NSURLRequest(URL: NSURL(string: self.weiboInfo.avastar_large!)!)
                let session = NSURLSession.sharedSession()
                let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
                    if error != nil
                    {
                        print(error?.code)
                        print(error?.description)
                    }
                    else
                    {
                        let image = UIImage.init(data: data!)
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            let imageView = cell?.viewWithTag(1) as! UIImageView
                            imageView.image = image
                        })
                    }
                }
                dataTask.resume()
            } else {
                let image = UIImage.init(data: weiboInfo.avastar_large_data!)
                dispatch_async(dispatch_get_main_queue(), {
                    let imageView = cell?.viewWithTag(1) as! UIImageView
                    imageView.image = image
                })
            }
            
            let name = cell?.viewWithTag(2) as! UILabel
            name.text = self.weiboInfo.userName

            let contentView = (cell?.viewWithTag(3))! as UIView
            let contentLable = contentView.viewWithTag(31) as! LinkLabel
            contentLable.attributedText = textProcessing(weiboInfo.content!)
            contentLable.frame = CGRectMake(0, 0, contentView.bounds.width, 0)
            contentLable.sizeToFit()
            let contentLableHeight = contentLable.frame.height
            
            let contentImage = contentView.viewWithTag(32)! as UIView
            contentImage.frame.origin.y = contentLable.frame.size.height+5
            for i in 1...9 {
                let imageShow = contentImage.viewWithTag(contentImage.tag*10+i) as! UIImageView
                imageShow.frame.size.height = 0
            }
            if weiboInfo.thumbnail_pic!.count > 0 {
                var rowCount = 0
                if (weiboInfo.thumbnail_pic?.count)! % 3 > 0 {
                    rowCount = (weiboInfo.thumbnail_pic?.count)! / 3 + 1
                } else {
                    rowCount = (weiboInfo.thumbnail_pic?.count)! / 3
                }
                let imageViewHeight = 85 * rowCount
                contentImage.frame.size.height = CGFloat(imageViewHeight)
                for i in 1...weiboInfo.thumbnail_pic!.count {
                    if weiboInfo.thumbnail_pic_data![weiboInfo.thumbnail_pic![i-1]] == nil {
                        let requestImage = NSURLRequest(URL: NSURL(string: weiboInfo.thumbnail_pic![i-1])!)
                        let sessionImage = NSURLSession.sharedSession()
                        let dataTaskImage = sessionImage.dataTaskWithRequest(requestImage) { (data, response, error) in
                            if error != nil
                            {
                                print(error?.code)
                                print(error?.description)
                            }
                            else
                            {
                                self.weiboInfo.thumbnail_pic_data![self.weiboInfo.thumbnail_pic![i-1]] = data!
                                dispatch_async(dispatch_get_main_queue(), {
                                    let image = UIImage.init(data: data!)
                                    let imageShow = contentImage.viewWithTag(contentImage.tag*10+i) as! UIImageView
                                    imageShow.frame.size.height = CGFloat(80)
                                    imageShow.contentMode = .ScaleToFill
                                    imageShow.image = image
                                })
                            }
                        }
                        dataTaskImage.resume()
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            let image = UIImage.init(data: self.weiboInfo.thumbnail_pic_data![self.weiboInfo.thumbnail_pic![i-1]]!)
                            let imageShow = contentImage.viewWithTag(contentImage.tag*10+i) as! UIImageView
                            imageShow.frame.size.height = CGFloat(80)
                            imageShow.image = image
                        })
                    }
                }
            } else {
                contentImage.frame = CGRectMake(0, 0, 260, 0)
            }
            let retweetedContentView = contentView.viewWithTag(33)! as UIView
            let retweetedContentLable = retweetedContentView.viewWithTag(331) as! LinkLabel
            let retweetedContentImage = retweetedContentView.viewWithTag(332)! as UIView
            if (weiboInfo.retweeted_info != nil ) {
                let text = "@" + (weiboInfo.retweeted_info?.userName)! + ": " + (weiboInfo.retweeted_info?.content)!
                retweetedContentLable.attributedText = textProcessing(text)
                retweetedContentLable.frame = CGRectMake(5, 5, retweetedContentView.bounds.width-10, 0)
                retweetedContentLable.sizeToFit()
                
                retweetedContentImage.frame.origin.y = retweetedContentLable.frame.size.height + 5
                let imageWidth: CGFloat = (retweetedContentView.bounds.width - 5) / 3
                for i in 1...9 {
                    let imageShow = retweetedContentImage.viewWithTag(retweetedContentImage.tag*10+i) as! UIImageView
                    imageShow.frame.size.height = 0
                    imageShow.image = nil
                }
                if weiboInfo.retweeted_info?.thumbnail_pic_data?.count > 0 {
                    var rowCount = 0
                    if (weiboInfo.retweeted_info?.thumbnail_pic_data?.count)! % 3 > 0 {
                        rowCount = (weiboInfo.retweeted_info?.thumbnail_pic_data?.count)! / 3 + 1
                    } else {
                        rowCount = (weiboInfo.retweeted_info?.thumbnail_pic_data?.count)! / 3
                    }
                    let imageViewHeight = imageWidth * CGFloat(rowCount)+10
                    retweetedContentImage.frame.size.height = CGFloat(imageViewHeight)
                    for i in 1...weiboInfo.retweeted_info!.thumbnail_pic_data!.count {
                        dispatch_async(dispatch_get_main_queue(), {
                            let image = UIImage.init(data: (self.weiboInfo.retweeted_info?.thumbnail_pic_data![(self.weiboInfo.retweeted_info?.thumbnail_pic![i-1])!]!)!)
                            let imageShow = retweetedContentImage.viewWithTag(retweetedContentImage.tag*10+i) as! UIImageView
                            imageShow.frame.size.height = CGFloat(imageWidth-5)
                            imageShow.image = image
                        })
                    }
                } else {
                    retweetedContentImage.frame = CGRectMake(0, 0, retweetedContentView.bounds.width, 0)
                }
                
                retweetedContentView.frame.origin.y = contentLable.frame.origin.y + contentLable.frame.size.height + 5
                retweetedContentView.frame.size.height = retweetedContentLable.frame.height + retweetedContentImage.frame.height
            } else {
                retweetedContentView.frame.size.height = 0
                retweetedContentLable.frame.size.height = 0
                retweetedContentLable.text = nil
            }
            if weiboInfo.retweeted_info != nil {
                weiboInfo.contentHeight = contentLableHeight + retweetedContentView.frame.height
            } else {
                weiboInfo.contentHeight = contentLableHeight
            }
            if weiboInfo.thumbnail_pic != nil {
                weiboInfo.contentHeight = weiboInfo.contentHeight + contentImage.frame.height
            }
            contentView.frame.size.height = weiboInfo.contentHeight
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(commentCellId)
            if cell == nil {
                cell = createCell(2, reuseIdentifier: commentCellId)
            }
            let commentInfo = commentDataSource[indexPath.row - 1]
            let name = cell?.viewWithTag(2) as! UILabel
            name.text = commentInfo.userName
            
            let content = cell?.viewWithTag(3) as! LinkLabel
            content.attributedText = textProcessing(commentInfo.content!)
            content.frame = CGRectMake(50, 40, self.view.bounds.width-60, 0)
            content.sizeToFit()
            content.frame.size.height = content.frame.height
            commentInfo.contentHeight = content.frame.height
            
            let request = NSURLRequest(URL: NSURL(string: commentInfo.avastar_large_url!)!)
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
                if error != nil
                {
                    print(error?.code)
                    print(error?.description)
                }
                else
                {
                    let image = UIImage.init(data: data!)
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let imageView = cell?.viewWithTag(1) as! UIImageView
                        imageView.image = image
                    })
                }
            }
            dataTask.resume()
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat?
        if indexPath.row == 0 {
            height = self.weiboInfo.contentHeight+55
        } else {
            height = self.commentDataSource[indexPath.row-1].contentHeight+50
        }
        return height!
    }
    
    func createCell(style: Int, reuseIdentifier: String?) -> UITableViewCell{
        let cell = UITableViewCell(style: .Default, reuseIdentifier: reuseIdentifier)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if style == 1 {
            let image = UIImageView(frame: CGRectMake(10, 10, 30, 30))
            image.tag = 1
            image.backgroundColor = UIColor.lightGrayColor()
            image.layer.cornerRadius = 5
            image.layer.masksToBounds = true
            cell.addSubview(image)
            
            let name = UILabel(frame: CGRectMake(50, 10, self.view.bounds.width-60, 20))
            name.tag = 2
            name.numberOfLines = 1
            name.font = UIFont.boldSystemFontOfSize(CGFloat(14))
            name.textColor = UIColor.brownColor()
            cell.addSubview(name)
            
            //显示微博内容
            let contentView = UIView(frame: CGRectMake(10, 45, self.view.bounds.width-20, 0))
            contentView.tag = 3
            cell.addSubview(contentView)
            
            //使用LinkLabel
            let content = LinkLabel(frame: CGRectMake(0, 0, contentView.bounds.width, 0))
            content.tag = 31
            content.numberOfLines = 0
            content.interactionDelegate = self
            content.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 0)
            content.font = UIFont.systemFontOfSize(CGFloat(12))
            contentView.addSubview(content)
            
            let imageView = UIView(frame: CGRectMake(0, 0, 260, 0))
            imageView.tag = 32
            contentView.addSubview(imageView)
            for i in 0..<9 {
                let image = UIImageView(frame: CGRectMake(CGFloat(i%3*85)+5, CGFloat(i/3*85), 80, 0))
                image.tag = imageView.tag * 10 + i + 1
                image.backgroundColor = UIColor.lightGrayColor()
                image.contentMode = .ScaleToFill
                imageView.addSubview(image)
            }
            
            //转发内容
            let retweetedContentView = UIView(frame: CGRectMake(0, 0, contentView.bounds.width, 0))
            retweetedContentView.tag = 33
            retweetedContentView.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 0.5)
            contentView.addSubview(retweetedContentView)
            
            //使用LinkLabel
            let retweetedContent = LinkLabel(frame: CGRectMake(0, 0, retweetedContentView.bounds.width, 0))
            retweetedContent.tag = 331
            retweetedContent.numberOfLines = 0
            retweetedContent.interactionDelegate = self
            retweetedContent.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 0)
            retweetedContent.font = UIFont.systemFontOfSize(CGFloat(12))
            retweetedContentView.addSubview(retweetedContent)
            
            let retweetedImageView = UIView(frame: CGRectMake(0, 0, retweetedContentView.bounds.width, 0))
            retweetedImageView.tag = 332
            retweetedContentView.addSubview(retweetedImageView)
            let imageWidth: CGFloat = (retweetedContentView.bounds.width - 5) / 3
            for i in 1...9 {
                let image = UIImageView(frame: CGRectMake(CGFloat((i-1)%3)*imageWidth+5, CGFloat((i-1)/3)*imageWidth+5, imageWidth-5, 0))
                image.tag = retweetedImageView.tag * 10 + i
                image.backgroundColor = UIColor.lightGrayColor()
                image.contentMode = .ScaleToFill
                retweetedImageView.addSubview(image)
            }
        } else {
            let image = UIImageView(frame: CGRectMake(10, 10, 30, 30))
            image.tag = 1
            image.backgroundColor = UIColor.lightGrayColor()
            image.layer.cornerRadius = 15
            image.layer.masksToBounds = true
            cell.addSubview(image)
            
            let name = UILabel(frame: CGRectMake(50, 10, self.view.bounds.width-60, 20))
            name.tag = 2
            name.numberOfLines = 1
            name.font = UIFont.systemFontOfSize(CGFloat(12))
            name.textColor = UIColor.brownColor()
            cell.addSubview(name)
            
            //使用LinkLabel
            let content = LinkLabel(frame: CGRectMake(50, 40, self.view.bounds.width-60, 0))
            content.tag = 3
            content.numberOfLines = 0
            content.interactionDelegate = self
            content.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 0)
            content.font = UIFont.systemFontOfSize(CGFloat(12))
            cell.addSubview(content)
        }
        
        return cell
    }
    
    func loadCommentsDataSource() {
        let commentsUrl = "https://api.weibo.com/2/comments/show.json"
        let accessToken: String? = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String
        let params = NSMutableDictionary()
        params.setValue(weiboInfo.weiboId!.stringValue , forKey: "id")
        params.setValue("\(page)", forKey: "page")
        params.setValue("20", forKey: "count")
        //        print(params)
        //使用新浪的openAPI
        _ = WBHttpRequest(accessToken: accessToken, url: commentsUrl, httpMethod: "GET", params: params as [NSObject : AnyObject], delegate: self, withTag: nil)
    }
    
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves)
        let dataSource = json!["comments"] as? NSArray
        self.totalNumber = json!["total_number"] as! Int
        if dataSource == nil {
            print("获取微博评论数据失败")
            let alert = UIAlertController(title: "错误", message: "获取微博评论数据失败", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancle", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.commentDataSource.removeAll()
            //            print("正在解析微博评论数据")
            for currentComment: AnyObject in dataSource! {
                let weiboComment = weiboCommentItem()
                weiboComment.content = currentComment["text"] as? String
                let userInfo = currentComment["user"]
                weiboComment.userName = (userInfo as! NSDictionary)["name"] as? String
                weiboComment.avastar_large_url = (userInfo as! NSDictionary)["avatar_large"] as? String
                self.commentDataSource.append(weiboComment)
            }
//            print("评论解析完毕")
//            for commentInfo in self.commentDataSource {
//                print("name:\(commentInfo.userName!)")
//                print("text:\(commentInfo.content!)\n")
//            }
            dispatch_async(dispatch_get_main_queue(), {
                self._tableView?.reloadData()
            })
        }
    }
    
    func calculateTextHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let attributes = [NSFontAttributeName: font]
        let text: NSString = text
        let size = text.boundingRectWithSize(CGSize(width: width, height: 0), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        return size.height
    }
    
    func textProcessing(string: String) -> NSAttributedString {
        let outString = NSMutableAttributedString(string: string)
        var rangeOfName = NSMakeRange(0, 0)
        var rangeOfLable = NSMakeRange(0, 0)
        var count = 0
        var finded_1 = false //用于标记@
        var finded_2 = false //用于标记#
        //高亮文本内容中的短链接
        var rangeOfURL = NSString(string: string).rangeOfString("http://t.cn/")
        if rangeOfURL.length != 0 {
            rangeOfURL.length += 7
            let r1 = string.startIndex.advancedBy(rangeOfURL.location)
            let r2 = string.endIndex.advancedBy((-outString.length + rangeOfURL.location) + rangeOfURL.length)
            let range = r1..<r2
            let shortURL = string.substringWithRange(range)
//            print(shortURL)
            outString.addAttribute(NSLinkAttributeName, value: NSURL(string: shortURL)!, range: rangeOfURL)
        }
        //高亮文本内容中@的名称和#...#
        for a in string.characters {
            count += 1
            if a == "@" {
                finded_1 = true
                rangeOfName.location = count - 1
            }
            if (a == "：" || a == ":" || a == " " || string.characters.count == count) && finded_1 == true {
                rangeOfName.length = count - rangeOfName.location
                outString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.35, green: 0.6, blue: 1.0, alpha: 1.0), range: rangeOfName)
                //                outString.addAttribute(NSLinkAttributeName, value: UIColor(red: 0.35, green: 0.6, blue: 1.0, alpha: 1.0), range: rangeOfName)
                finded_1 = false
            }
            
            if a == "#" {
                if finded_2 == false {
                    finded_2 = true
                    rangeOfLable.location = count - 1
                } else {
                    rangeOfLable.length = count - rangeOfLable.location
                    outString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.35, green: 0.6, blue: 1.0, alpha: 1.0), range: rangeOfLable)
                    //                    outString.addAttribute(NSLinkAttributeName, value: UIColor(red: 0.35, green: 0.6, blue: 1.0, alpha: 1.0), range: rangeOfLable)
                    finded_2 = false
                }
            }
        }
        
        return outString
    }
    
    func linkLabelDidSelectLink(linkLabel linkLabel: LinkLabel, url: NSURL) {
        print(url)
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
