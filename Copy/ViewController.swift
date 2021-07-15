//
//  ViewController.swift
//  Copy
//
//  Created by JaeHyeon on 2021/07/09.
//

import UIKit
import WebKit
import CoreLocation
import SafariServices

class ViewController: UIViewController,WKUIDelegate,WKNavigationDelegate,CLLocationManagerDelegate,SFSafariViewControllerDelegate {
    @IBOutlet var webView: WKWebView!
    var locationManager: CLLocationManager!
    
    var tuple = [
        URL(string: "https://semos.kr/"),
        URL(string: "https://semos.kr/location"),
        URL(string: "https://semos.kr/market"),
        URL(string: "https://semos.kr/my_page"),
    ]
    
    @objc func checkUrl(){
        self.webView?.allowsBackForwardNavigationGestures = tuple.contains(webView.url!) ? false : true
        // if it is one of the main page, do not allow backward gesture
        let temp = webView.url?.absoluteString
        if (temp!.contains("payment"))
        {
            // if it is payment site, open it with SVC due to kakaopay
            let tmp = webView.url!
            webView.goBack()
//            webView.load(URLRequest(url: URL(string: "https://semos.kr/")!))
            let safariViewController = SFSafariViewController(url: tmp)
            safariViewController.delegate = self
            safariViewController.modalPresentationStyle = .automatic
            // to make SVC pop-up
            self.present(safariViewController, animated: true, completion: nil)
        }
        
    }
    
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        webView.load(URLRequest(url: URL(string: "https://semos.kr/")!))
    }
    
    // if there is a gesture at main page, change view
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if (tuple.contains(webView.url!)){
            if let swipeGesture = gesture as? UISwipeGestureRecognizer{
                switch swipeGesture.direction {
                    case UISwipeGestureRecognizer.Direction.left :
                        let index = tuple.firstIndex(of: webView.url!)!
                        if (index < 3) {
                            webView.load(URLRequest(url: tuple[index + 1]!))
                        }
                    case UISwipeGestureRecognizer.Direction.right :
                        let index = tuple.firstIndex(of: webView.url!)!
                        if (index > 0) {
                            webView.load(URLRequest(url: tuple[index - 1]!))
                        }
                    default:
                        break
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        self.webView.uiDelegate = self
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)

        
        
//        webView.evaluateJavaScript("navigator.userAgent"){(result, error) in
//            let originUserAgent = result as! String
//            let agent = originUserAgent + " Semos_webview_IOS"
//            self.webView.customUserAgent = agent
//        }

        locationManager.requestWhenInUseAuthorization()
        let request = URLRequest(url: URL(string: "https://semos.kr")!)

        WKWebpagePreferences().allowsContentJavaScript = true
        self.webView.load(request)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        // set status bar white
        if #available(iOS 13.0, *) {
            let statusBarHeight: CGFloat = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = UIColor.white
            view.addSubview(statusbarView)
          
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
          
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor.white
        }
        
//        if #available(iOS 11.0, *) {
//            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
//                for cookie in cookies{
//                    print("@@@ cookie ==> \(cookie.name) : \(cookie.value)")
//                    if cookie.name == "PHPSESSID" {
//                        UserDefaults.standard.set(cookie.value, forKey:"PHPSESSID")
//                        print("@@@ PHPSESSID 저장하기: \(cookie.value)")
//
//                    }
//
//                }
//
//            }
//
//        } else {
//            // Fallback on earlier versions
//        }
//
//        let cookie_domain = "https://semos.kr"
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            let loadedSessid = UserDefaults.standard.value(forKey: "PHPSESSID") as! String?
//            if let temp = loadedSessid{
//                print("@@@ PHPSESSID 저장~~: \(temp)")
//                // 이게 정상동작하는듯.. 자동로그인 됨
//                let cookieString : String = "document.cookie='PHPSESSID=\(temp);path=/;domain=\(cookie_domain);'"
//                webView.evaluateJavaScript(cookieString)
//            }
//
//        }
        
    }
    
    // set status bar letter black
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    // alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
        print("alert")
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler() }))
        self.present(alertController, animated: true, completion: nil) }


    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let tmp = navigationAction.request.url?.absoluteString

            if (tmp!.contains("chat")){
                UIApplication.shared.open(navigationAction.request.url!, options: [:])
            }
//            else {
//                print("!!!!!!!")
////                let kakaoTalk = "kakaotalk://v1/payment/ready"
////                let kakaoTalkURL = NSURL(string: kakaoTalk)
////                if (UIApplication.shared.canOpenURL(kakaoTalkURL! as URL)) {
////
////                            //open(_:options:completionHandler:) 메소드를 호출해서 카카오톡 앱 열기
////                            UIApplication.shared.open(kakaoTalkURL! as URL)
////                        }
////                        //사용 불가능한 URLScheme일 때(카카오톡이 설치되지 않았을 경우)
////                        else {
////                            print("No kakaotalk installed.")
////                        }
//
//                if let url = navigationAction.request.url {
//                   let urlPath: String = url.absoluteString.removingPercentEncoding!
//                    print(urlPath)
//                    print("^^^^^")
//                }
//
////                UIApplication.shared.open(navigationAction.request.url!, options: [:])
//            }
//            print("@@@@@")
//        }
        }
        return nil
    }
    
    // detact url change
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("URL Change 1:", webView.url?.absoluteString ?? "No value provided")
        checkUrl()
//        if object as AnyObject? === webView && keyPath == "URL" {
//            print("URL Change 1:", webView.url?.absoluteString ?? "No value provided")
//            checkUrl()
//        }
    }
}
