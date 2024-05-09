//
//  WKWebView.swift
//  RssReader
//

import SwiftUI
import SafariServices

struct WebView: View {
    var url: URL
    init(_ url: URL) {
        self.url = url
//        let config = SFSafariViewController.Configuration()
//        config.entersReaderIfAvailable = true
//        config.barCollapsingEnabled = true
//        let vc =  CustomSafariViewController(url: url, configuration: config)
//        UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
    }
    var body: some View {
        NavigationView {
                   ZStack {
                       Color("Background").edgesIgnoringSafeArea(.all)
                       
                        SafariView(url: url)
                   }
               }
        
    }
}
struct SafariView: UIViewControllerRepresentable{
    let url: URL
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        config.barCollapsingEnabled = true
        let vc = CustomSafariViewController(url: url, configuration: config)
        return vc
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

class CustomSafariViewController: SFSafariViewController {

    override init(url URL: URL, configuration: SFSafariViewController.Configuration) {
        super.init(url: URL, configuration: configuration)
    delegate = self
    preferredBarTintColor = UIColor(named: "Background")
    preferredControlTintColor = .white
  }
}

// MARK: - SFSafariViewControllerDelegate

extension CustomSafariViewController: SFSafariViewControllerDelegate {
  internal func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    controller.dismiss(animated: true)
  }
}


//
//struct WebView: UIViewRepresentable {
//    var url: URL
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        uiView.load(URLRequest(url: url))
//        let readingModeOnScript = """
//            if (typeof ReaderView !== 'undefined') {
//                ReaderView.show();
//            } else {
//                alert('Reading mode is not supported in this browser.');
//            }
//        """
//        uiView.evaluateJavaScript(readingModeOnScript)
//    }
//}
