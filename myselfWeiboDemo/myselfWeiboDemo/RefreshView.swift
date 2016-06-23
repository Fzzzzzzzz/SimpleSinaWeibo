//
//  RefreshView.swift
//  myselfWeiboDemo
//
//  Created by 傅中正 on 16/6/3.
//  Copyright © 2016年 Eric‘s Project. All rights reserved.
//

import UIKit

protocol RefreshViewDelegate: class {
    func refreshViewDidRefresh(refreshView: RefreshView)
}

private var kSceneHeight: CGFloat = 50.0

class RefreshView: UIView, UIScrollViewDelegate {
    private unowned var scrollView: UIScrollView
    private var progress: CGFloat = 0.0
    
    var refreshItems = [RefreshItem]()
    weak var delegate: RefreshViewDelegate?
    var isRefreshing = false
    
    init(frame: CGRect, scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        setupRefreshItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRefreshItems() {
        let refreshLabel = UILabel()
        refreshLabel.frame.size = CGSize(width: 100, height: 24)
        refreshLabel.font = UIFont.boldSystemFontOfSize(CGFloat(14))
        refreshLabel.text = "下拉刷新"
        refreshLabel.textColor = UIColor.lightGrayColor()
        refreshLabel.textAlignment = .Center
        
        refreshItems = [RefreshItem(view: refreshLabel, centerEnd: CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetHeight(bounds) - CGRectGetHeight(refreshLabel.bounds)), parallaxRatio: 1.0, sceneHeight: kSceneHeight)]
        
        for refreshItem in refreshItems {
            addSubview(refreshItem.view)
        }
    }
    
    func updateBackgroundColor() {
        backgroundColor = UIColor(white: 0.7 * progress + 0.2, alpha: 1.0)
    }
    
    func updateRefreshItemPosition() {
        for refreshItem in refreshItems {
            refreshItem.updateViewPositionForPercentage(progress)
        }
    }
    
    func beginRefreshing() {
        isRefreshing = true
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.scrollView.contentInset.top = kSceneHeight
            }) { (_) in
                
        }
    }
    
    func endRefreshing() {
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: {
            self.scrollView.contentInset.top = 0
        }) { (_) in
            self.isRefreshing = false
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !isRefreshing && progress == 1 {
            beginRefreshing()
            targetContentOffset.memory.y = -scrollView.contentInset.top
            delegate?.refreshViewDidRefresh(self)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if isRefreshing {
            return
        }
        
        hidden = false
        
        let refreshViewVisibleHeight = max(0, -scrollView.contentOffset.y - scrollView.contentInset.top)
        progress = min(1, refreshViewVisibleHeight / kSceneHeight)
        if progress == 1 {
            let label = refreshItems[0].view as! UILabel
            label.text = "松开并刷新"
        } else {
            let label = refreshItems[0].view as! UILabel
            label.text = "下拉刷新"
        }
//        updateBackgroundColor()
        updateRefreshItemPosition()
    }
}
