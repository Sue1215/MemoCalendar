//
//  task.swift
//  CalendarApp
//
//  Created by sue on 2017/11/11.
//  Copyright © 2017年 sue. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // 内容
    @objc dynamic var contents = ""
    
    /// 日時、TaskクラスにdateというStringプロパティを追加
    @objc dynamic var date = NSDate()
    //　毎週繰り返し
    @objc dynamic var isWeekRepeat = false
    
    //　毎付き繰り返し
    @objc dynamic var isMonthRepeat = false
    
    //　毎年繰り返し
    @objc dynamic var isYearRepeat = false
    
    //Int型とする
    @objc dynamic var day = 0
    @objc dynamic var weekday = 0
    @objc dynamic var month = 0
    @objc dynamic var year = 0
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
        
        
    }
}
