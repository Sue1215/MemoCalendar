//
//  ViewController.swift
//  CalendarApp
//
//  Created by sue on 2017/11/10.
//  Copyright © 2017年 sue. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift
import UserNotifications

class ViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate,  UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarHeightConstraint: UINavigationItem!
    
    @IBOutlet weak var taskManage: UITableView!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート true
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true) 

    
        override func viewDidLoad() {
        super.viewDidLoad()
        //画面上のタイトル
        self.title = "Calendar"
        // Do any additional setup after loading the view, typically from a nib.
        
        taskManage.delegate = self
        taskManage.dataSource = self
            
            
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //年・月・週・日を取得
        let cal = NSCalendar.current
        let weekday = cal.component(.weekday, from: date)
        let month = cal.component(.month, from: date)
        let year = cal.component(.year, from: date)
        let day = cal.component(.day, from: date)
        
        print("day: \(day),weekday: \(weekday), month: \(month), year: \(year)")
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
//        let nextDate = date.addingTimeInterval(24*60*60) // 1日後
//        let predicate = NSPredicate(format: "date >= %@ and date < %@", date as CVarArg, nextDate as CVarArg)
        
        let predicate = NSPredicate(format:
            "(isWeekRepeat == false and isMonthRepeat == false and isYearRepeat == false and year == %i and month == %i and day == %i) or " +
                "(isWeekRepeat == true and weekday == %i and date <= %@) or " +
                "(isMonthRepeat == true and day == %i and date <= %@) or " +
            "(isYearRepeat == true and month == %i and day == %i and date <= %@)",
                                    year, month, day,
                                    weekday, date as CVarArg,
                                    day, date as CVarArg,
                                    month, day, date as CVarArg)
        
        taskArray = try! Realm().objects(Task.self).filter(predicate).sorted(byKeyPath: "date", ascending: true)
        taskManage.reloadData()
    }

    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)

    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.taskManage.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            
            if let date = calendar.selectedDate {
                task.date = date as NSDate
            }
//            task.date = calendar.selectedDate! as NSDate
            
            if try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true).count != 0 {
                task.id = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true).max(ofProperty: "id")! + 1
                    //taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskManage.reloadData()
    }
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
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
}
}




