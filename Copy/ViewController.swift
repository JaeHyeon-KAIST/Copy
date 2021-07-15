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
    
    @objc func updateTime(){
        self.webView?.allowsBackForwardNavigationGestures = tuple.contains(webView.url!) ? false : true
        let temp = webView.url?.absoluteString
        if (temp!.contains("payment"))
        {
            let tmp = webView.url!
            webView.goBack()
            let safariViewController = SFSafariViewController(url: tmp)
            safariViewController.delegate = self
            safariViewController.modalPresentationStyle = .automatic
            self.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        webView.load(URLRequest(url: URL(string: "https://semos.kr")!))
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 만일 제스쳐가 있다면
        if (tuple.contains(webView.url!)){
            if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            // 발생한 이벤트가 각 방향의 스와이프 이벤트라면 해당 이미지 뷰를 빨간색 화살표 이미지로 변경
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
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        webView.uiDelegate = self
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        
//        webView.evaluateJavaScript("navigator.userAgent"){(result, error) in
//            let originUserAgent = result as! String
//            let agent = originUserAgent + " Semos_webview_IOS"
//            self.webView.customUserAgent = agent
//        }

        locationManager.requestWhenInUseAuthorization()
        let request = URLRequest(url: URL(string: "https://semos.kr")!)
//        let request = URLRequest(url: URL(string: "https://naver.com")!)

        WKWebpagePreferences().allowsContentJavaScript = true
        webView.load(request)
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
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
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent // Set status bar letter black
    }
    
    //alert 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
        print("alert")
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler() }))
        self.present(alertController, animated: true, completion: nil) }

//
//
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
}
