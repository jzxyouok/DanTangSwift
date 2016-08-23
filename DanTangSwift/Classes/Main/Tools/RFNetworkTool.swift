//
//  RFNetworkTool.swift
//  DanTangSwift
//
//  Created by rocky on 16/8/12.
//  Copyright © 2016年 RockyFung. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON


class RFNetworkTool: NSObject {

    // 单例
    static let shareNetworkTool = RFNetworkTool()
    
    // 获取首页顶部分类数据
    func loadHomeTopData(finished: (rf_channels: [RFChannel]) -> ()){
        let url = BASE_URL + "v2/channels/preset"
        let params = ["gender":1,
                     "generation":1]
       Alamofire
        .request(.GET, url, parameters: params)
        .responseJSON{response in
            guard response.result.isSuccess else{
                SVProgressHUD.showErrorWithStatus("加载失败。。。")
                return
            }
            
            if let value = response.result.value{
                let dict = JSON(value)
                let code = dict["code"].intValue
                let message = dict["message"].stringValue
                guard code == RETURN_OK else{
                    SVProgressHUD.showInfoWithStatus(message)
                    return
                }
                SVProgressHUD.dismiss()
                
                let data = dict["data"].dictionary
                if let channels = data!["channels"]?.arrayObject{
                    var rf_channels = [RFChannel]()
                    for channel in channels{
                        let rf_channel = RFChannel(dict:channel as! [String: AnyObject])
                        rf_channels.append(rf_channel)
                    }
                    finished(rf_channels:rf_channels)
                }
            }
            
        }
        
    }
    
    
    // 获取首页数据
    func loadHomeInfo(id: Int, finished: (homeItems: [RFHomeItem]) -> ()){
        let url = BASE_URL + "v1/channels/\(id)/items"
        let params = ["gender": 1,
                      "generation":1,
                      "limit":20,
                      "offset":0]
        Alamofire
        .request(.GET, url, parameters: params)
        .responseJSON { (response) in
            guard response.result.isSuccess else{
                SVProgressHUD.showErrorWithStatus("加载失败...")
                return
            }
            
            if let value = response.result.value{
                let dict = JSON(value)
                let code = dict["code"].intValue
                let message = dict["message"].stringValue
                guard code == RETURN_OK else{
                    SVProgressHUD.showErrorWithStatus(message)
                    return
                }
                
                let data = dict["data"].dictionary
                // 字典转模型
                if let items = data!["items"]?.arrayObject{
                    var homeItems = [RFHomeItem]()
                    for item in items{
                        let homeItem = RFHomeItem(dict: item as! [String: AnyObject])
                        homeItems.append(homeItem)
                    }
                    finished(homeItems: homeItems)
                }
            }
        }
    
    }
    
    // 搜索界面数据
    func loadHotWords(finished:(words: [String]) -> ()){
        SVProgressHUD.showWithStatus("正在加载...")
        let url = BASE_URL + "v1/search/hot_words"
        Alamofire
        .request(.GET, url)
        .responseJSON { (response) in
            guard response.result.isSuccess else{
                SVProgressHUD.showErrorWithStatus("加载失败...")
                return
            }
            if let value = response.result.value {
                let dict = JSON(value)
                let code = dict["code"].intValue
                let message = dict["message"].stringValue
                guard code == RETURN_OK else{
                    SVProgressHUD.showInfoWithStatus(message)
                    return
                }
                SVProgressHUD.dismiss()
                if let data = dict["data"].dictionary {
                    if let hot_words = data["hot_words"]?.arrayObject{
                        finished(words: hot_words as! [String])
                    }
                }
            }
        }
    }
    
    // 根据搜索条件进行搜索
    func loadSearchResult(keyword: String, sort: String, finished:(results: [RFSearchResult]) -> ()){
        SVProgressHUD.showWithStatus("正在加载...")
        let url = "http://api.dantangapp.com/v1/search/item"
        let params = ["keyword": keyword,
                      "limit": 20,
                      "offset": 0,
                      "sort": sort]
        Alamofire
            .request(.GET, url, parameters: params as? [String: AnyObject])
        .responseJSON { (response) in
            guard response.result.isSuccess else{
                SVProgressHUD.showErrorWithStatus("加载失败...")
                return
            }
            
            if let value = response.result.value {
                let dict = JSON(value)
                let code = dict["code"].intValue
                let message = dict["message"].stringValue
                guard code == RETURN_OK else{
                    SVProgressHUD.showInfoWithStatus(message)
                    return
                }
                
                SVProgressHUD.dismiss()
                let data = dict["data"].dictionary
                if let items = data!["items"]?.arrayObject {
                    var results = [RFSearchResult]()
                    for item in items {
                        let result = RFSearchResult(dict: item as! [String: AnyObject])
                        results.append(result)
                    }
                    finished(results: results)
                }
            }
        }
    }
    
    
    // 获取单品数据
    func loadProductData(finished:(products: [RFProduct]) -> ()){
        SVProgressHUD.showWithStatus("正在加载。。。")
        let url = BASE_URL + "v2/items"
        let params = ["gender": 1,
                      "generation": 1,
                      "limit": 20,
                      "offset": 0]
        
        Alamofire
        .request(.GET, url, parameters: params)
        .responseJSON { (response) in
            guard response.result.isSuccess else{
                SVProgressHUD.showWithStatus("加载失败...")
                return
            }
            
            if let value = response.result.value {
                let dict = JSON(value)
                let code = dict["code"].intValue
                let message = dict["message"].stringValue
                
                guard code == RETURN_OK else{
                    SVProgressHUD.showInfoWithStatus(message)
                    return
                }
                SVProgressHUD.dismiss()
                if let data = dict["data"].dictionary{
                    if let items = data["items"]?.arrayObject{
                        var products = [RFProduct]()
                        for item in items{
                            if let itemData = item["data"]{
                                let product = RFProduct(dict: itemData as! [String: AnyObject])
                                products.append(product)
                            }
                        }
                        finished(products: products)
                    }
                }
            }
        }
    }
    
    // 获取单品详情数据
    func loadProductDetailData(id: Int, finished:(productDetail: RFProductDetail) -> ()){
        SVProgressHUD.showWithStatus("正在加载...")
        let url = BASE_URL + "v2/items/\(id)"
        Alamofire
        .request(.GET, url)
        .responseJSON { (response) in
            guard response.result.isSuccess else{
                SVProgressHUD.showErrorWithStatus("加载失败...")
                return
            }
            
            if let value = response.result.value {
                let dict = JSON(value)
                let code = dict["code"].intValue
                let message = dict["message"].stringValue
                guard code == RETURN_OK else{
                    SVProgressHUD.showErrorWithStatus(message)
                    return
                }
                
                SVProgressHUD.dismiss()
                if let data = dict["data"].dictionaryObject {
                    let productDetail = RFProductDetail(dict: data)
                    finished(productDetail: productDetail)
                }
            }
        }
    }
    
    // 商品详情评论
    func loadProductDetailComments(id: Int, finished:(comments: [RFComment]) -> ()){
        SVProgressHUD.showErrorWithStatus("正在加载...")
        let url = BASE_URL + "v2/items/\(id)/comments"
        let params = ["limit": 20,
                      "offset": 0]
        
        Alamofire
        .request(.GET, url, parameters: params)
        .responseJSON { (response) in
            guard response.result.isSuccess else{
                SVProgressHUD.showErrorWithStatus("加载失败...")
                return
            }
            
            if let value = response.result.value {
                let dict = JSON(value)
                let code = dict["code"].intValue
                let message = dict["message"].stringValue
                
                guard code == RETURN_OK else{
                    SVProgressHUD.showErrorWithStatus(message)
                    return
                }
                
                SVProgressHUD.dismiss()
                
                if let data = dict["data"].dictionary {
                    if let commentsData = data["comments"]?.arrayObject{
                        var comments = [RFComment]()
                        for item in commentsData{
                            let comment = RFComment(dict: item as! [String: AnyObject])
                            comments .append(comment)
                        }
                        finished(comments: comments)
                    }
                }
            }
        }
    }
    
    
    
    
    
}




































