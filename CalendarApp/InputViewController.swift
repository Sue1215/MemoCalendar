//
//  InputViewController.swift
//  CalendarApp
//
//  Created by sue on 2017/11/11.
//  Copyright © 2017年 sue. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var repeatSegmentedControl: UISegmentedControl!
    
    var task: Task!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date as Date
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
        
        override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date as NSDate
            self.realm.add(self.task, update: true)
            if repeatSegmentedControl.selectedSegmentIndex == 0 {
                // day
                self.task.isWeekRepeat = false
                self.task.isMonthRepeat = false
                self.task.isYearRepeat = false
            } else if repeatSegmentedControl.selectedSegmentIndex == 1 {
                // week
                self.task.isWeekRepeat = true
                self.task.isMonthRepeat = false
                self.task.isYearRepeat = false
            } else if repeatSegmentedControl.selectedSegmentIndex == 2 {
                // month
                self.task.isWeekRepeat = false
                self.task.isMonthRepeat = true
                self.task.isYearRepeat = false
            } else if repeatSegmentedControl.selectedSegmentIndex == 3 {
                // year
                self.task.isWeekRepeat = false
                self.task.isMonthRepeat = false
                self.task.isYearRepeat = true
            }
            let cal = NSCalendar.current
            self.task.day = cal.component(.day, from: self.datePicker.date)
            self.task.weekday = cal.component(.weekday, from: self.datePicker.date)
            self.task.month = cal.component(.month, from: self.datePicker.date)
            self.task.year = cal.component(.year, from: self.datePicker.date)
            
            }
    
            
            setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    // タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.title
        if content.title == "" {
            content.title = "(タイトルなし)"
        }
        content.body  = task.contents       // bodyが空だと音しか出ない
        if content.body == "" {
            content.body = "(内容なし)"
        }
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = NSCalendar.current
        _ = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
        //let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 1, minute: 5, weekday: 2), repeats: true)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
        // 各セルを選択した時に実行されるメソッド
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "cellSegue",sender: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


