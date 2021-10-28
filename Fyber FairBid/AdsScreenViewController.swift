//
//
// Copyright (c) 2019 Fyber. All rights reserved.
//
//

import FairBidSDK
import UIKit

class AdsScreenViewController: UIViewController {

    var adType: AdType!
    
    private let admobPmnInterstitialPlacementID = "442811"
    private let admobPmnRewardedPlacementID = "442813"
    private let admobPmnBannerPlacementID = "442815"
    
    private let secondAdmobPmnInterstitialPlacementID = "442812"
    private let secondAdmobPmnRewardedPlacementID = "442814"
    private let secondAdmobPmnBannerPlacementID = "442816"

    let formatter = DateFormatter()

    private var banner: FYBBannerAdView?
    private var callbackStrings: [String] = []

    // MARK: - Outlets

    @IBOutlet var callBacksTableView: UITableView!

    @IBOutlet var unitImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var placementIdLabel: UILabel!
    @IBOutlet var callbackLabel: UILabel!

    @IBOutlet var requestButton: UIButton!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var cleanCallbacksButton: UIButton!

    @IBOutlet var bannerView: UIView!
    @IBOutlet var seperator: UIView!

    @IBOutlet var bannerHeight: NSLayoutConstraint!

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.dateFormat = "HH:mm:ss"

        showButton.disable()
        switch adType! {
        case .interstitial:
            FYBInterstitial.delegate = self
            placementIdLabel.text = admobPmnInterstitialPlacementID
            if FYBInterstitial.isAvailable(admobPmnInterstitialPlacementID) {
                adIsAvailable()
            }
        case .rewarded:
            FYBRewarded.delegate = self
            placementIdLabel.text = admobPmnRewardedPlacementID
            if FYBRewarded.isAvailable(admobPmnRewardedPlacementID) {
                adIsAvailable()
            }
        case .banner:
            FYBBanner.delegate = self
            placementIdLabel.text = admobPmnBannerPlacementID
        case .second_interstitial:
            FYBInterstitial.delegate = self
            placementIdLabel.text = secondAdmobPmnInterstitialPlacementID
            if FYBInterstitial.isAvailable(secondAdmobPmnInterstitialPlacementID) {
                adIsAvailable()
            }
        case .second_rewarded:
            FYBRewarded.delegate = self
            placementIdLabel.text = secondAdmobPmnRewardedPlacementID
            if FYBRewarded.isAvailable(secondAdmobPmnRewardedPlacementID) {
                adIsAvailable()
            }
        case .second_banner:
            FYBBanner.delegate = self
            placementIdLabel.text = secondAdmobPmnBannerPlacementID
        }
        
        

        if adType! == .banner {
            requestButton.setTitle("Show", for: .normal)
            showButton.setTitle("Destroy", for: .normal)
        } else {
            requestButton.setTitle("Request", for: .normal)
            showButton.setTitle("Show", for: .normal)

            bannerView.removeFromSuperview()
        }

        callBacksTableView.tableFooterView = UIView(frame: .zero)

        title = adType.rawValue
        navigationController?.navigationBar.topItem?.title = ""

        unitImage.image = UIImage(named: adType.rawValue)!
    }

    // MARK: - Service

    @IBAction func requestAdClicked(_ sender: Any) {
        switch adType! {
        case .interstitial:
            FYBInterstitial.request(admobPmnInterstitialPlacementID)
        case .rewarded:
            FYBRewarded.request(admobPmnRewardedPlacementID)
        case .banner:
            let bannerOptions = FYBBannerOptions()
            bannerOptions.placementId = admobPmnBannerPlacementID

            FYBBanner.show(in: bannerView, position: .top, options: bannerOptions)
        case .second_interstitial:
            FYBInterstitial.request(secondAdmobPmnInterstitialPlacementID)
        case .second_rewarded:
            FYBRewarded.request(secondAdmobPmnRewardedPlacementID)
        case .second_banner:
            let bannerOptions = FYBBannerOptions()
            bannerOptions.placementId = secondAdmobPmnBannerPlacementID
            
            FYBBanner.show(in: bannerView, position: .top, options: bannerOptions)
        }

        fetchingInProgress()
    }

    @IBAction func showOrDestroyAdClicked(_ sender: Any) {
        switch adType! {
        case .interstitial:
            FYBInterstitial.show(admobPmnInterstitialPlacementID)
        case .rewarded:
            FYBRewarded.show(admobPmnRewardedPlacementID)
        case .banner:
            banner?.removeFromSuperview()
            adDismissed()
        case .second_interstitial:
            FYBInterstitial.show(secondAdmobPmnInterstitialPlacementID)
        case .second_rewarded:
            FYBRewarded.show(secondAdmobPmnRewardedPlacementID)
        case .second_banner:
            banner?.removeFromSuperview()
            adDismissed()
        }
    }

    @IBAction func cleanAndHideCallbackList(_ sender: Any) {
        callbackStrings = []
        reloadTableView()
    }

    func fetchingInProgress() {
        requestButton.setTitleColor(.clear, for: .normal)
        requestButton.disable()
        activityIndicator.startAnimating()
    }

    func adIsAvailable() {
        requestButton.setTitleColor(.white, for: .normal)
        requestButton.disable()
        showButton.enable()
        activityIndicator.stopAnimating()
    }

    func adDismissed() {
        requestButton.setTitleColor(.white, for: .normal)
        requestButton.enable()
        showButton.disable()
        activityIndicator.stopAnimating()
    }

    func addEventToCallbacksList(_ callback: String) {
        callbackStrings.append(stringFromDate(Date()) + " " + callback)
        reloadTableView()
        scrollToBottom()
    }

    func stringFromDate(_ date: Date) -> String {
        return formatter.string(from: date)
    }

    func reloadTableView() {
        setCallbacksTable(hidden: callbackStrings.isEmpty)
        callBacksTableView.reloadData()
    }

    func scrollToBottom() {
        let indexPath = IndexPath(row: callbackStrings.count - 1, section: 0)
        self.callBacksTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func setCallbacksTable(hidden: Bool) {
        callBacksTableView.isHidden = hidden
        cleanCallbacksButton.isHidden = hidden
        callbackLabel.isHidden = hidden
        seperator.isHidden = hidden
    }

}

extension AdsScreenViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callbackStrings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Callback cell", for: indexPath)
        cell.textLabel?.text = callbackStrings[indexPath.row]
        return cell
    }

}

extension AdsScreenViewController: FYBInterstitialDelegate {

    func interstitialIsAvailable(_ placementName: String) {
        addEventToCallbacksList(#function)
        adIsAvailable()
    }

    func interstitialIsUnavailable(_ placementName: String) {
        adDismissed()
        addEventToCallbacksList(#function)
    }

    func interstitialDidShow(_ placementName: String, impressionData: FYBImpressionData) {
        addEventToCallbacksList(#function)
    }
    
    func interstitialDidFail(toShow placementId: String, withError error: Error, impressionData: FYBImpressionData) {
        addEventToCallbacksList(#function)
    }

    func interstitialDidClick(_ placementName: String) {
        addEventToCallbacksList(#function)
    }

    func interstitialDidDismiss(_ placementName: String) {
        adDismissed()
        addEventToCallbacksList(#function)
    }

    func interstitialWillStartAudio() {
        addEventToCallbacksList(#function)
    }

    func interstitialDidFinishAudio() {
        addEventToCallbacksList(#function)
    }

}

extension AdsScreenViewController: FYBRewardedDelegate {

    func rewardedIsAvailable(_ placementName: String) {
        adIsAvailable()
        addEventToCallbacksList(#function)
    }

    func rewardedIsUnavailable(_ placementName: String) {
        adDismissed()
        addEventToCallbacksList(#function)
    }

    func rewardedDidShow(_ placementName: String, impressionData: FYBImpressionData) {
        addEventToCallbacksList(#function)
    }

    func rewardedDidFail(toShow placementName: String, withError error: Error) {
        addEventToCallbacksList(#function)
    }

    func rewardedDidClick(_ placementName: String) {
        addEventToCallbacksList(#function)
    }

    func rewardedDidComplete(_ placementName: String, userRewarded: Bool) {
        addEventToCallbacksList(#function)
    }

    func rewardedDidDismiss(_ placementName: String) {
        adDismissed()
        addEventToCallbacksList(#function)
    }

    func rewardedWillStartAudio() {
        addEventToCallbacksList(#function)
    }

    func rewardedDidFinishAudio() {
        addEventToCallbacksList(#function)
    }

}

extension AdsScreenViewController: FYBBannerDelegate {

    func bannerDidLoad(_ banner: FYBBannerAdView) {
        self.banner = banner
        bannerHeight.constant = banner.bounds.height + 20
        adIsAvailable()
        addEventToCallbacksList(#function)
    }

    func bannerDidFail(toLoad placementName: String, withError error: Error) {
        addEventToCallbacksList(#function)
        adDismissed()
    }

    func bannerDidShow(_ banner: FYBBannerAdView, impressionData: FYBImpressionData) {
        addEventToCallbacksList(#function)
    }

    func bannerDidClick(_ banner: FYBBannerAdView) {
        addEventToCallbacksList(#function)
    }

    func bannerWillPresentModalView(_ banner: FYBBannerAdView) {
        addEventToCallbacksList(#function)
    }

    func bannerDidDismissModalView(_ banner: FYBBannerAdView) {
        addEventToCallbacksList(#function)
    }

    func bannerWillLeaveApplication(_ banner: FYBBannerAdView) {
        addEventToCallbacksList(#function)
    }

    func banner(_ banner: FYBBannerAdView, didResizeToFrame frame: CGRect) {
        addEventToCallbacksList(#function)
    }

}

private extension UIButton {

    func enable() {
        isEnabled = true
        backgroundColor = UIColor(red: 29/255.0, green: 0/255.0, blue: 71/255.0, alpha: 1)
    }

    func disable() {
        isEnabled = false
        backgroundColor = UIColor(red: 197/255.0, green: 208/255.0, blue: 222/255.0, alpha: 1)
    }
}
