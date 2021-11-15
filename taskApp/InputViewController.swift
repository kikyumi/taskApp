//
//  InputViewController.swift
//  taskApp
//
//  Created by 菊川 由美 on 2021/11/11.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    let realm = try! Realm()
    var task: Task!   // 追加する
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 背景をタップしたらcloseKeyboard()を呼ぶデフォルト設定
        let tapBackground: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tapBackground)
        
        titleTextField.text = task.title
        contentTextView.text = task.contents
        datePicker.date = task.date
        cateTextField.text = task.category
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        try! realm.write(){
            task.title = titleTextField.text!
            task.contents = contentTextView.text
            task.date = datePicker.date
            task.category = cateTextField.text!
            realm.add(task, update: .modified)
            
        }
    }
    
    //キーボードを閉じる
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    
    // タスクのローカル通知を登録する --- ここから ---
        func setNotification(task: Task) {
            let content = UNMutableNotificationContent()
            // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
            if task.title == "" {
                content.title = "(タイトルなし)"
            } else {
                content.title = task.title
            }
            if task.contents == "" {
                content.body = "(内容なし)"
            } else {
                content.body = task.contents
            }
            content.sound = UNNotificationSound.default

            // ローカル通知が発動するtrigger（日付マッチ）を作成
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
            let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

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
        } // --- ここまで追加 ---

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
