//
//  ViewController.swift
//  sampleSnapShot
//
//  Created by yuka on 2017/12/20.
//  Copyright © 2017年 yuka. All rights reserved.
//

import UIKit
import WebKit
import Photos

class ViewController: UIViewController
    ,UIWebViewDelegate
{
    // appDeligateをインスタンス化
    let appDeligate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    var capturedImage : UIImage?
    
    @IBOutlet weak var calenderWebView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calenderWebView.delegate = self
        appDeligate.loadFile(webViewName:calenderWebView, resource: "index", type: "html")
        

    }
    

    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(#function)

        if(request.url!.scheme == "scheme") {
            
            let components: NSURLComponents? = NSURLComponents(string: request.url!.absoluteString)
            for i in 0 ..< (components?.queryItems?.count)! {
                let page = (components?.queryItems?[i])! as URLQueryItem
                if page.name == "camera" {
                    snapshot()
                    notifyToWebView()
                }
            }
            return false
        }
        return true
    }
    

    
    func snapshot() {
        capturedImage = getScreenShot() as UIImage

        //UIImageWriteToSavedPhotosAlbum(capturedImage!, nil, #selector(checkPhotoLibraryAuthorizedState), nil)
        UIImageWriteToSavedPhotosAlbum(capturedImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)


    }
    
    func notifyToWebView() {
        let sendMessage = "var $status = \"saved\";"
        calenderWebView.stringByEvaluatingJavaScript(from: sendMessage)
    }
    
    private func getScreenShot() -> UIImage {
        var heightSize:CGFloat
        
        if( UIDevice.current.userInterfaceIdiom == .pad) {
            heightSize = 582
        }
        else {
            heightSize = 430
        }

    
        let rect:CGRect = CGRect(x: 0, y: 0, width: calenderWebView.frame.width, height: heightSize)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.view.layer.render(in: context)
        let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return capturedImage
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func checkPhotoLibraryAuthorizedState() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.restricted {
            print("status == ALAuthorizationStatus.Restricted")
            // フォトライブラリにアクセスすることを許可されていない状態
            
        } else if status == PHAuthorizationStatus.denied {
            print("status == ALAuthorizationStatus.Denied")
            // ユーザが明示的にフォトライブラリのアクセスを拒否した状態
            
        } else if status == PHAuthorizationStatus.authorized {
            print("status == ALAuthorizationStatus.Authorized")
            // ユーザがフォトライブラリへのアクセスを承認している状態
            let title = "保存"
            let body  = "カメラロールに保存されました"
            alertAction1(s_title: title, s_message: body, s_action: "OK")
            
        } else if status == PHAuthorizationStatus.notDetermined {
            print("status == ALAuthorizationStatus.NotDetermined")
            // ユーザがフォトライブラリへのアクセスの選択を行っていない状態
                let title = "確認"
                let body  = "カメラロールに保存できませんでした。設定を確認してください。"
                alertAction1(s_title: title, s_message: body, s_action: "OK")
        }
        
        
        
    }

    func alertAction1(s_title:String, s_message:String, s_action:String){
        
        
        //部品となるアラート
        let alert = UIAlertController(
            title: s_title ,
            message: s_message,
            preferredStyle: .alert
        )
        
        //ボタンを増やしたいときは、addActionをもう一つ作ればよい
        alert.addAction(
            UIAlertAction(
                title: s_action,
                style: .default,
                handler: nil)
        )
        
        // アラート表示
        present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

