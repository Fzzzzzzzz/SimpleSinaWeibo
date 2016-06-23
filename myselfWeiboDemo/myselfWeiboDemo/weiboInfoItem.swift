//
//  weiboInfoItem.swift
//  myselfWeiboDemo
//
//  Created by 傅中正 on 16/4/27.
//  Copyright © 2016年 Eric‘s Project. All rights reserved.
//

import Foundation

class weiboInfoItem {
    var userName: String? = ""
    var weiboId: NSNumber?
    var createTime: String? = ""
    var content: String? = ""
    var contentHeight: CGFloat = 0
    var avastar_large: String? = ""
    var avastar_large_data: NSData?
    var thumbnail_pic: [String]?
    var thumbnail_pic_data: Dictionary<String, NSData>?
    var large_pic: [String]?
    var large_pic_data: Dictionary<String, NSData>?
    var pic_ids: [String]?
    var retweeted_info: weiboInfoItem?
}

class weiboCommentItem {
    var userName: String? = ""
    var content: String? = ""
    var contentHeight: CGFloat = 0
    var avastar_large_url: String? = ""
}