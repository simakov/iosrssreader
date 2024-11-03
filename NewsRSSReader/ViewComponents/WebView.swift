//
//  WKWebView.swift
//  RssReader
//
import SwiftUI
import SafariServices

struct WebView: View {
    var url: URL
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                SafariView(url: url, onDone: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    var onDone: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onDone: onDone)
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        config.barCollapsingEnabled = true
        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.delegate = context.coordinator
        safariVC.preferredBarTintColor = UIColor(named: "Background")
        safariVC.preferredControlTintColor = .white
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariView
        var onDone: () -> Void
        
        init(_ parent: SafariView, onDone: @escaping () -> Void) {
            self.parent = parent
            self.onDone = onDone
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            onDone()
        }
    }
}
