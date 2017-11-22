//
//  InputViewController.swift
//  CalendarApp
//
//  Created by sue on 2017/11/11.
//  Copyright © 2017年 sue. All rights reserved.
//

import UIKit
import RealmSwift

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //上のボタンの作成
        let myRightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onClickMyButton(_:)))
        self.navigationItem.rightBarButtonItem = myRightButton
    }
    
    @objc func onClickMyButton(_ sender:Any) {
        // ここにボタンが押された時の処理を追加
    }
    
    // Do any additional setup after loading the view.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

