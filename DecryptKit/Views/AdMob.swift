//
//  AdMob.swift
//  deCripple
//
//  Created by Amir Mohammadi on 11/29/1401 AP.
//

import SwiftUI
import UIKit
import GoogleMobileAds

class BannerAdVC: UIViewController {
  
  //Initialize variable
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  var bannerView = GADBannerView(adSize: GADAdSizeFullBanner)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    bannerView.rootViewController = self
    view.addSubview(bannerView)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    bannerView.load(GADRequest())
  }
}

struct BannerAd: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> BannerAdVC {
    return BannerAdVC()
  }
  
  func updateUIViewController(_ uiViewController: BannerAdVC, context: Context) {
  }
}
