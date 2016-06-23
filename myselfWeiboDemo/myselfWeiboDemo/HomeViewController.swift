
//  FirstViewController.swift
//  myselfWeiboDemo
//
//  Created by 傅中正 on 16/4/26.
//  Copyright © 2016年 Eric‘s Project. All rights reserved.
//

import UIKit

private let kRefreshViewHeight: CGFloat = 200

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WBHttpRequestDelegate, UIScrollViewDelegate, UITextViewDelegate, RefreshViewDelegate, UIGestureRecognizerDelegate, TYAttributedLabelDelegate, LinkLabelInteractionDelegate {

    var scrollView: UIScrollView?
    var homeTableView: UITableView?
    var hotTableView: UITableView?
    var refreshView_1: RefreshView?
    var refreshView_2: RefreshView?
    var homeDataSource = [weiboInfoItem]()
    var hotDataSource = [weiboInfoItem]()
    var topBtn: UIButton?
    var maxPage = 1
    var tagPage = 0//0: 首页 1: 热门
    var nameLock = true
    
    var reopenApp = true
    
    var onceToken: dispatch_once_t = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("viewDidLoad")
        
        self.navigationItem.title = "首页"
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(white: 0.95, alpha: 0.5)
        
        let leftButtonItem = UIBarButtonItem(title: "菜单", style: .Plain, target: self, action: #selector(HomeViewController.showMenu(_:)))
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        let rightButtonItem = UIBarButtonItem(title: "发微", style: .Plain, target: self, action: #selector(HomeViewController.writeNewTweet))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        scrollView = UIScrollView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height-64-49))
        scrollView?.contentSize = CGSizeMake(self.scrollView!.bounds.width * 2, self.scrollView!.bounds.height)
        scrollView?.backgroundColor = UIColor.whiteColor()
        scrollView?.pagingEnabled = true
        scrollView?.bounces = false
//        scrollView?.alwaysBounceVertical = false
        scrollView?.directionalLockEnabled = true
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.delegate = self
        self.view.addSubview(scrollView!)
        
        //首页
        homeTableView = UITableView(frame: CGRectMake(0, 0, scrollView!.bounds.width, scrollView!.bounds.height))
        homeTableView?.tag = 1
        homeTableView?.dataSource = self
        homeTableView?.delegate = self
        homeTableView?.scrollEnabled = true
        homeTableView?.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
        scrollView?.addSubview(homeTableView!)
        let homeFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        homeTableView?.tableFooterView = homeFooterView
        
        refreshView_1 = RefreshView(frame: CGRect(x: 0, y: -kRefreshViewHeight, width: CGRectGetWidth((homeTableView?.bounds)!), height:  kRefreshViewHeight), scrollView: homeTableView!)
        refreshView_1?.delegate = self
        refreshView_1?.hidden = true
        homeTableView?.insertSubview(refreshView_1!, atIndex: 0)
        
        //热门
        hotTableView = UITableView(frame: CGRectMake(self.view.bounds.width, 0, scrollView!.bounds.width, scrollView!.bounds.height))
        hotTableView?.tag = 2
        hotTableView?.dataSource = self
        hotTableView?.delegate = self
        hotTableView?.scrollEnabled = true
        hotTableView?.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
        scrollView?.addSubview(hotTableView!)
        let hotFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        hotTableView?.tableFooterView = hotFooterView
        
        refreshView_2 = RefreshView(frame: CGRect(x: 0, y: -kRefreshViewHeight, width: CGRectGetWidth((homeTableView?.bounds)!), height:  kRefreshViewHeight), scrollView: homeTableView!)
        refreshView_2?.delegate = self
        refreshView_2?.hidden = true
        hotTableView?.insertSubview(refreshView_2!, atIndex: 0)
        
        //返回顶部
        topBtn = UIButton(frame: CGRectMake(self.view.bounds.width-50, self.view.bounds.height-184, 45, 40))
        topBtn!.setTitle("^Top", forState: .Normal)
        topBtn!.backgroundColor = UIColor.lightGrayColor()
        topBtn!.layer.cornerRadius = 5
        topBtn!.alpha = CGFloat(0.5)
        topBtn!.hidden = true
        topBtn!.addTarget(self, action: #selector(HomeViewController.scrollToTop), forControlEvents: .TouchUpInside)
        self.view.addSubview(topBtn!)
        
        self.loadDataSource(1)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
    }
    
    func refreshViewDidRefresh(refreshView: RefreshView) {
        if refreshView == refreshView_1 {
            loadDataSource(1)
        } else if refreshView == refreshView_2 {
            loadDataSource(2)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == homeTableView {
            refreshView_1?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        } else if scrollView == hotTableView {
            refreshView_2?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            if nameLock == false {
                let indexOfPage = scrollView.contentOffset.x / self.view.bounds.width
                switch indexOfPage {
                case 0:
                    self.navigationItem.title = "首页"
                default:
                    self.navigationItem.title = "热门"
                    if hotDataSource.count == 0 {
                        loadDataSource(2)
                    }
                }
                nameLock = true
            }
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == homeTableView {
            refreshView_1?.scrollViewDidScroll(scrollView)
        } else if scrollView == hotTableView {
            refreshView_2?.scrollViewDidScroll(scrollView)
        }
        if scrollView.contentOffset.x > 0 && nameLock == true {
            nameLock = false
        }
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.x == 0 {
            topBtn?.hidden = false
        } else if scrollView.contentOffset.y <= 0 && scrollView.contentOffset.x == 0{
            topBtn?.hidden = true
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if nameLock == false {
            let indexOfPage = scrollView.contentOffset.x / self.view.bounds.width
            switch indexOfPage {
            case 0:
                self.navigationItem.title = "首页"
            default:
                self.navigationItem.title = "热门"
                if hotDataSource.count == 0 {
                    loadDataSource(2)
                }
            }
            nameLock = true
        }
    }
    
    func scrollToTop() {
        let indexOfPage = scrollView!.contentOffset.x / self.view.bounds.width
        switch indexOfPage {
        case 0:
            homeTableView!.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        case 1:
            hotTableView!.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return homeDataSource.count
        } else if tableView.tag == 2 {
            return hotDataSource.count
        }
        
        return homeDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var weiboInfo = self.homeDataSource[indexPath.row]
        switch tableView.tag {
        case 1:
            weiboInfo = self.homeDataSource[indexPath.row]
        case 2:
            weiboInfo = self.hotDataSource[indexPath.row]
        default:
            weiboInfo = self.homeDataSource[indexPath.row]
        }
        let cellid = "cellid"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellid)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellid)
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            cell?.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
            //显示用户头像
            let image = UIImageView(frame: CGRectMake(10, 10, 30, 30))
            image.tag = 1
            image.backgroundColor = UIColor.lightGrayColor()
            image.layer.cornerRadius = 5
            image.layer.masksToBounds = true
            cell?.addSubview(image)
            
            //显示用户微博名
            let name = UILabel(frame: CGRectMake(50, 10, self.view.bounds.width-80, 20))
            name.tag = 2
            name.numberOfLines = 1
            name.font = UIFont.boldSystemFontOfSize(CGFloat(14))
            name.textColor = UIColor.brownColor()
            cell?.addSubview(name)
            
            //显示微博内容
            let contentView = UIView(frame: CGRectMake(50, 40, self.view.bounds.width-80, 0))
            contentView.tag = 3
            cell?.addSubview(contentView)
            
            //使用LinkLabel
            let content = LinkLabel(frame: CGRectMake(0, 0, contentView.bounds.width, 0))
            content.tag = 31
            content.numberOfLines = 0
            content.interactionDelegate = self
            content.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 0)
            content.font = UIFont.systemFontOfSize(CGFloat(12))
            contentView.addSubview(content)
            
            let imageView = UIView(frame: CGRectMake(0, 0, contentView.bounds.width, 0))
            imageView.tag = 32
            contentView.addSubview(imageView)
            let imageWidth: CGFloat = (contentView.bounds.width) / 3
            for i in 0..<9 {
                let image = UIImageView(frame: CGRectMake(CGFloat(i%3)*imageWidth, 0, imageWidth-5, 0))
                image.tag = imageView.tag * 10 + i + 1
                image.backgroundColor = UIColor.whiteColor()
                image.contentMode = .ScaleToFill
                image.userInteractionEnabled = true
                let onTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.clickPicture(_:)))
                onTap.numberOfTouchesRequired = 1; //手指数
                onTap.numberOfTapsRequired = 1; //tap次数
                onTap.delegate = self
                image.addGestureRecognizer(onTap)
                imageView.addSubview(image)
                let label = UILabel()
                image.addSubview(label)
            }
            
            //显示转发内容
            let retweetedContentView = UIView(frame: CGRectMake(0, 0, contentView.bounds.width, 0))
            retweetedContentView.tag = 33
//            retweetedContentView.userInteractionEnabled = true
            retweetedContentView.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 0.5)
            contentView.addSubview(retweetedContentView)

            //使用LinkLabel
            let retweetedContent = LinkLabel(frame: CGRectMake(5, 5, retweetedContentView.bounds.width-10, 0))
            retweetedContent.tag = 331
            retweetedContent.numberOfLines = 0
            retweetedContent.userInteractionEnabled = true
            retweetedContent.interactionDelegate = self
            retweetedContent.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 0)
            retweetedContent.font = UIFont.systemFontOfSize(CGFloat(12))
            retweetedContentView.addSubview(retweetedContent)
            
            let retweetedImageView = UIView(frame: CGRectMake(5, 0, retweetedContentView.bounds.width, 0))
            retweetedImageView.tag = 332
            retweetedContentView.addSubview(retweetedImageView)
            let retweetedImageWidth: CGFloat = (retweetedContentView.bounds.width-5)/3
            for i in 0..<9 {
                let image = UIImageView(frame: CGRectMake(CGFloat(i%3)*retweetedImageWidth, 0, retweetedImageWidth-5, 0))
                image.tag = retweetedImageView.tag * 10 + i + 1
                image.backgroundColor = UIColor.whiteColor()
                image.contentMode = .ScaleToFill
                image.userInteractionEnabled = true
                let onTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.clickPicture(_:)))
                image.addGestureRecognizer(onTap)
                onTap.numberOfTouchesRequired = 1; //手指数
                onTap.numberOfTapsRequired = 1; //tap次数
                onTap.delegate = self
                retweetedImageView.addSubview(image)
                let label = UILabel()
                image.addSubview(label)
            }
        }
        
        //获取用户头像
        if weiboInfo.avastar_large_data == nil {
            let request = NSURLRequest(URL: NSURL(string: weiboInfo.avastar_large!)!)
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
                if error != nil
                {
                    print(error?.code)
                    print(error?.description)
                }
                else
                {
                    weiboInfo.avastar_large_data = data
                    dispatch_async(dispatch_get_main_queue(), {
                        let image = UIImage.init(data: data!)
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
        
        //用户名
        let name = cell?.viewWithTag(2) as! UILabel
        name.text = weiboInfo.userName
        
        //获取微博内容
        let contentView = (cell?.viewWithTag(3))! as UIView
        let contentLable = contentView.viewWithTag(31) as! LinkLabel
        contentLable.attributedText = textProcessing(weiboInfo.content!)
        contentLable.frame = CGRectMake(0, 0, contentView.bounds.width, 0)
        contentLable.sizeToFit()
        let contentLableHeight = contentLable.frame.height
        
        let contentImage = contentView.viewWithTag(32)! as UIView
        contentImage.frame.origin.y = contentLable.frame.size.height
        let imageWidth: CGFloat = (contentView.bounds.width) / 3
        for i in 1...9 {
            let imageShow = contentImage.viewWithTag(contentImage.tag*10+i) as! UIImageView
            imageShow.frame.size.height = 0
            imageShow.image = nil
            let label = imageShow.subviews.first as! UILabel
            label.text = nil
        }
        if weiboInfo.thumbnail_pic!.count > 0 {
            var rowCount = 0
            if (weiboInfo.thumbnail_pic?.count)! % 3 > 0 {
                rowCount = (weiboInfo.thumbnail_pic?.count)! / 3 + 1
            } else {
                rowCount = (weiboInfo.thumbnail_pic?.count)! / 3
            }
            let imageViewHeight = imageWidth * CGFloat(rowCount)
            contentImage.frame.size.height = CGFloat(imageViewHeight)
            for i in 0..<weiboInfo.thumbnail_pic!.count {
                if weiboInfo.thumbnail_pic_data![weiboInfo.thumbnail_pic![i]] == nil {
                    let requestImage = NSURLRequest(URL: NSURL(string: weiboInfo.thumbnail_pic![i])!)
                    let sessionImage = NSURLSession.sharedSession()
                    let dataTaskImage = sessionImage.dataTaskWithRequest(requestImage) { (data, response, error) in
                        if error != nil
                        {
                            print(error?.code)
                            print(error?.description)
                        }
                        else
                        {
                            weiboInfo.thumbnail_pic_data![weiboInfo.thumbnail_pic![i]] = data!
                            dispatch_async(dispatch_get_main_queue(), {
                                let image = UIImage.init(data: data!)
                                let imageShow = contentImage.viewWithTag(contentImage.tag*10+(i+1)) as! UIImageView
                                imageShow.frame.origin.y = CGFloat(i / 3) * imageWidth + 5
                                imageShow.frame.size.height = imageWidth-5
                                imageShow.image = image
                                (imageShow.subviews.first as! UILabel).text = weiboInfo.thumbnail_pic![i]
                            })
                        }
                    }
                    dataTaskImage.resume()
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        let image = UIImage.init(data: weiboInfo.thumbnail_pic_data![weiboInfo.thumbnail_pic![i]]!)
                        let imageShow = contentImage.viewWithTag(contentImage.tag*10+(i+1)) as! UIImageView
                        imageShow.frame.origin.y = CGFloat(i / 3) * imageWidth + 5
                        imageShow.frame.size.height = imageWidth-5
                        imageShow.image = image
                        (imageShow.subviews.first as! UILabel).text = weiboInfo.thumbnail_pic![i]
                    })
                }
            }
        } else {
            contentImage.frame = CGRectMake(0, 0, contentView.bounds.width, 0)
        }
        
        //转发内容
        let retweetedContentView = contentView.viewWithTag(33)! as UIView
        let retweetedContentLable = retweetedContentView.viewWithTag(331) as! LinkLabel
        let retweetedContentImage = retweetedContentView.viewWithTag(332)! as UIView
        if (weiboInfo.retweeted_info != nil ) {
            let text = "@" + (weiboInfo.retweeted_info?.userName)! + ": " + (weiboInfo.retweeted_info?.content)!
            retweetedContentLable.attributedText = textProcessing(text)
            retweetedContentLable.frame = CGRectMake(5, 5, retweetedContentView.bounds.width-10, 0)
            retweetedContentLable.sizeToFit()

            retweetedContentImage.frame.origin.y = retweetedContentLable.frame.height+10
            let retweetedImageWidth: CGFloat = (retweetedContentView.bounds.width - 5) / 3
            for i in 1...9 {
                let imageShow = retweetedContentImage.viewWithTag(retweetedContentImage.tag*10+i) as! UIImageView
                imageShow.frame.origin.y = 0
                imageShow.frame.size.height = 0
                imageShow.image = nil
                let label = imageShow.subviews.first as! UILabel
                label.text = nil
            }
            if weiboInfo.retweeted_info!.thumbnail_pic!.count > 0 {
                var rowCount = 0
                if (weiboInfo.retweeted_info?.thumbnail_pic?.count)! % 3 > 0 {
                    rowCount = (weiboInfo.retweeted_info?.thumbnail_pic?.count)! / 3 + 1
                } else {
                    rowCount = (weiboInfo.retweeted_info?.thumbnail_pic?.count)! / 3
                }
                let imageViewHeight = retweetedImageWidth * CGFloat(rowCount)
                retweetedContentImage.frame.size.height = CGFloat(imageViewHeight)+5
                for i in 0..<weiboInfo.retweeted_info!.thumbnail_pic!.count {
                    if weiboInfo.retweeted_info?.thumbnail_pic_data![(weiboInfo.retweeted_info?.thumbnail_pic![i])!] == nil {
                        let requestImage = NSURLRequest(URL: NSURL(string: (weiboInfo.retweeted_info?.thumbnail_pic![i])!)!)
                        let sessionImage = NSURLSession.sharedSession()
                        let dataTaskImage = sessionImage.dataTaskWithRequest(requestImage) { (data, response, error) in
                            if error != nil
                            {
                                print(error?.code)
                                print(error?.description)
                            }
                            else
                            {
                                weiboInfo.retweeted_info?.thumbnail_pic_data![(weiboInfo.retweeted_info?.thumbnail_pic![i])!] = data!
                                dispatch_async(dispatch_get_main_queue(), {
                                    let image = UIImage.init(data: data!)
                                    let imageShow = retweetedContentImage.viewWithTag(retweetedContentImage.tag*10+i+1) as! UIImageView
                                    imageShow.frame.origin.y = CGFloat(i / 3) * retweetedImageWidth
                                    imageShow.frame.size.height = CGFloat(retweetedImageWidth-5)
                                    imageShow.image = image
                                    (imageShow.subviews.first as! UILabel).text = (weiboInfo.retweeted_info?.thumbnail_pic![i])!
                                })
                            }
                        }
                        dataTaskImage.resume()
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            let image = UIImage.init(data: (weiboInfo.retweeted_info?.thumbnail_pic_data![(weiboInfo.retweeted_info?.thumbnail_pic![i])!]!)!)
                            let imageShow = retweetedContentImage.viewWithTag(retweetedContentImage.tag*10+i+1) as! UIImageView
                            imageShow.frame.origin.y = CGFloat(i / 3) * retweetedImageWidth
                            imageShow.frame.size.height = CGFloat(retweetedImageWidth-5)
                            imageShow.image = image
                            (imageShow.subviews.first as! UILabel).text = (weiboInfo.retweeted_info?.thumbnail_pic![i])!
                        })
                    }
                }
            } else {
                retweetedContentImage.frame = CGRectMake(5, 0, retweetedContentView.bounds.width, 0)
            }
        
            retweetedContentView.frame.size.height = retweetedContentLable.frame.height + retweetedContentImage.frame.height + 5
            retweetedContentView.frame.origin.y = contentLable.frame.origin.y + contentLable.frame.size.height + 5
            weiboInfo.retweeted_info?.contentHeight = retweetedContentView.frame.size.height
        } else {
            retweetedContentView.frame.size.height = 0
            retweetedContentLable.frame.size.height = 0
            retweetedContentImage.frame.size.height = 0
            for i in 1...9 {
                let imageShow = retweetedContentImage.viewWithTag(retweetedContentImage.tag*10+i) as! UIImageView
                imageShow.frame.size.height = 0
                imageShow.image = nil
                let label = imageShow.subviews.first as! UILabel
                label.text = nil
            }
            retweetedContentLable.text = nil
        }
        
        if(weiboInfo.contentHeight == 0) {
            if weiboInfo.retweeted_info != nil {
                contentView.frame.size.height = contentLableHeight + 5 + (weiboInfo.retweeted_info?.contentHeight)!
            } else {
                contentView.frame.size.height = contentLableHeight
            }
            if weiboInfo.thumbnail_pic != nil {
                contentView.frame.size.height = contentView.frame.size.height + contentImage.frame.height
            }
            weiboInfo.contentHeight = contentView.frame.size.height
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = self.homeDataSource[indexPath.row].contentHeight + 50
        switch tableView.tag {
        case 1:
            height = self.homeDataSource[indexPath.row].contentHeight + 50
        case 2:
            height = self.hotDataSource[indexPath.row].contentHeight + 50
        default:
            break
        }
        return height
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        switch tableView.tag {
        case 1:
            if (homeDataSource.count - indexPath.row) == 4 {
                if reopenApp != true {
                    self.loadMoreData(tableView.tag)
                } else {
                    reopenApp = false
                }
            }
        case 2:
            if (hotDataSource.count - indexPath.row) == 4 {
                if reopenApp != true {
                    self.loadMoreData(tableView.tag)
                } else {
                    reopenApp = false
                }
            }
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = commentInfoViewController()
        switch tableView.tag {
        case 1:
            vc.weiboInfo = homeDataSource[indexPath.row]
        case 2:
            vc.weiboInfo = hotDataSource[indexPath.row]
        default:
            break
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadDataSource(tag: Int) {
        print("loadDataSource...")
        let HomeTimeLine = "https://api.weibo.com/2/statuses/home_timeline.json"
        let PublicTimeLine = "https://api.weibo.com/2/statuses/public_timeline.json"
        var url = HomeTimeLine
        var tagParam = "mainPage reload"
        switch tag {
        case 1:
            url = HomeTimeLine
            tagParam = "mainPage reload"
        case 2:
            url = PublicTimeLine
            tagParam = "hotPage reload"
        default:
            break
        }
        self.maxPage = 1
        let accessToken: String? = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String
        
        let params = NSMutableDictionary()
        params.setValue("\(maxPage)", forKey: "page")
        params.setValue("10", forKey: "count")
        //使用新浪的openAPI
        print("发送数据请求")
        _ = WBHttpRequest(accessToken: accessToken, url: url, httpMethod: "GET", params: params as [NSObject : AnyObject], delegate: self, withTag: tagParam)
    }
    
    func loadMoreData(tag: Int) {
        let HomeTimeLine = "https://api.weibo.com/2/statuses/home_timeline.json"
        let PublicTimeLine = "https://api.weibo.com/2/statuses/public_timeline.json"
        var url = HomeTimeLine
        var tagParam = "mainPage loadmore"
        switch tag {
        case 1:
            url = HomeTimeLine
            tagParam = "mainPage loadmore"
        case 2:
            url = PublicTimeLine
            tagParam = "hotPage loadmre"
        default:
            break
        }
        self.maxPage += 1
        let accessToken: String = (NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String)!
        let params = NSMutableDictionary()
        params.setValue("\(maxPage)", forKey: "page")
        params.setValue("10", forKey: "count")
        //使用新浪的openAPI
        _ = WBHttpRequest(accessToken: accessToken, url: url, httpMethod: "GET", params: params as [NSObject : AnyObject], delegate: self, withTag: tagParam)
    }
    
    func refreshData(refreshCtr: UIRefreshControl) {
        loadDataSource(refreshCtr.tag)
    }
    
    func request(request: WBHttpRequest!, didFinishLoadingWithDataResult data: NSData!) {
        print("receive data...")
        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves)
//        print(json)
        var dataTag = 1
        switch request.tag {
        case "mainPage reload":
            self.homeDataSource.removeAll()
            fallthrough
        case "mainPage loadmore":
            dataTag = 1
            
        case "hotPage reload":
            self.hotDataSource.removeAll()
            fallthrough
        case "mainPage loadmore":
            dataTag = 2
        default:
            print("other_tag:\(request.tag)")
            if request.tag == "loginOut" {
                print("请重新登录")
            }
            return 
        }
        let dataSource = json!["statuses"] as? NSArray
        if dataSource == nil {
            print("获取微博数据失败")
            let errorCode = json!["error_code"] as? NSNumber
            print("error_code = \(errorCode)")
            if errorCode == 21332 {
                self.presentViewController(LoginViewController(), animated: true, completion: nil)
                return
            }
            if dataTag == 1 {
                self.refreshView_1?.endRefreshing()
            } else if dataTag == 2 {
                self.refreshView_2?.endRefreshing()
            }
            let alert = UIAlertController(title: "错误", message: "获取微博数据失败", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancle", style: .Cancel, handler: { (cancelAction) in
                self.refreshAuth()
            })
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            print("正在解析微博数据")
//            print(dataSource)
            for currentWeibo: AnyObject in dataSource! {
                let weiboInfo = weiboInfoItem()
                self.analysisStatuseInfo(currentWeibo, weiboInfo: weiboInfo)
                switch dataTag {
                case 1:
                    self.homeDataSource.append(weiboInfo)
                case 2:
                    self.hotDataSource.append(weiboInfo)
                default:
                    self.homeDataSource.append(weiboInfo)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                switch dataTag {
                case 1:
                    self.homeTableView?.reloadData()
                    self.refreshView_1?.endRefreshing()
                case 2:
                    self.hotTableView?.reloadData()
                    self.refreshView_1?.endRefreshing()
                default:
                    break
                }
            })
        }
    }
    
    func refreshAuth() {
        let refreToken = NSUserDefaults.standardUserDefaults().objectForKey("refreshToken") as? String
        
        _ = WBHttpRequest(forRenewAccessTokenWithRefreshToken: refreToken, queue: nil) { (request, data, error) in
            let receiveData = data as! NSDictionary
            let accessToken = receiveData["access_token"]
            let refreshToken = receiveData["refresh_token"]
            if accessToken == nil {
                NSUserDefaults.standardUserDefaults().setObject("false", forKey: "loginState")
                self.presentViewController(LoginViewController(), animated: true, completion: nil)
            } else {
                NSUserDefaults.standardUserDefaults().setObject("true", forKey: "loginState")
                NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "accessToken")
                NSUserDefaults.standardUserDefaults().setObject(refreshToken, forKey: "refreshToken")
            }
        }
    }
    
    func calculateTextHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let attributes = [NSFontAttributeName: font]
        let text: NSString = text
        let size = text.boundingRectWithSize(CGSize(width: width, height: 0), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        return size.height
    }
    
    func analysisStatuseInfo(dataSource: AnyObject?, weiboInfo: weiboInfoItem) {
        if dataSource == nil {
            return
        }
        let wbDelete: AnyObject? = dataSource!["deleted"]
        if (wbDelete != nil) {
            weiboInfo.userName = ""
            weiboInfo.weiboId = nil
            weiboInfo.createTime = ""
            weiboInfo.content = "该条微博已经被原作者删除(或者隐藏为私密微博)"
            weiboInfo.avastar_large = nil
            weiboInfo.avastar_large_data = nil
            weiboInfo.thumbnail_pic = [String]()
            weiboInfo.thumbnail_pic_data = [String: NSData]()
            print("该条微博已经被原作者删除(或者隐藏为私密微博)")
            return
        }
        weiboInfo.createTime = dataSource!["created_at"] as? String
        weiboInfo.content = dataSource!["text"] as? String
        let pic_urls = dataSource!["pic_urls"] as? NSArray
        weiboInfo.thumbnail_pic = [String]()
        if pic_urls?.count != 0 {
            for thumbnail_pic: AnyObject in pic_urls! {
                let a = thumbnail_pic["thumbnail_pic"] as? String
                weiboInfo.thumbnail_pic?.append(a!)
//                weiboInfo.bmiddle_pic?.append(<#T##newElement: Element##Element#>)
            }
            weiboInfo.thumbnail_pic_data = [String: NSData]()
        }
        let retweeted_status: AnyObject? = dataSource!["retweeted_status"]
        if (retweeted_status != nil) {
            weiboInfo.retweeted_info = weiboInfoItem()
            analysisStatuseInfo(retweeted_status, weiboInfo: weiboInfo.retweeted_info!)
        }
        weiboInfo.weiboId = dataSource!["id"] as? NSNumber
        let userInfo = dataSource!["user"] as! NSDictionary
        weiboInfo.userName = userInfo["name"] as? String
        weiboInfo.avastar_large = userInfo["avatar_large"] as? String
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
                finded_1 = false
            }
            
            if a == "#" {
                if finded_2 == false {
                    finded_2 = true
                    rangeOfLable.location = count - 1
                } else {
                    rangeOfLable.length = count - rangeOfLable.location
                    outString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.35, green: 0.6, blue: 1.0, alpha: 1.0), range: rangeOfLable)
                    finded_2 = false
                }
            }
        }

        return outString
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        print(URL)
        return true
    }
    
    func attributedLabel(attributedLabel: TYAttributedLabel!, textStorageClicked textStorage: TYTextStorageProtocol!, atPoint point: CGPoint) {
        print(attributedLabel)
        print(point)
    }
    
    func linkLabelDidSelectLink(linkLabel linkLabel: LinkLabel, url: NSURL) {
        print(url)
    }
    
    func writeNewTweet() {
        let vc = NewTweetViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clickPicture(sender: UITapGestureRecognizer) {
        let view = sender.view as? UIImageView
        let vc = PictureViewController()
        vc.smallPic = view?.image
        vc.pictureUrl = (view?.subviews.first as! UILabel).text
        vc.modalTransitionStyle = .CrossDissolve
        self.presentViewController(vc, animated: true, completion: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func revokeoAuth() {
        let accessToken: String? = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate?.revokeoAuth()
//        WeiboSDK.logOutWithToken(accessToken!, delegate: self, withTag: "loginOut")
        self.presentViewController(LoginViewController(), animated: true, completion: nil)
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func test() {
        print("test")
    }
    
    func showMenu(sender: AnyObject) {

//        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        //KxMenu
        let menuItem1 = KxMenuItem("注销", image: nil, target: self, action: #selector(HomeViewController.revokeoAuth))

        var frame = sender.valueForKey("view")?.frame
        frame?.origin.y = (frame?.origin.y)!-35
        KxMenu.showMenuInView(self.view, fromRect: frame!, menuItems: [menuItem1])
    }
}

