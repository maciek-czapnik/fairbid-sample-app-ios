//
//  APSSupport.swift
//  Fyber FairBid
//
//  Created by Maciek Czapnik on 11/07/2022.
//  Copyright © 2022 Fyber. All rights reserved.
//

import Foundation
import FairBidSDK
import DTBiOSSDK

class APSSupport: NSObject
{
    static var shared: APSSupport = {
        let instance = APSSupport()
        return instance
    }()

    private let slotLoader = APSSlotLoader()

    func start() {
        addIABTCFToUserDefaults()
        FairBid.apsAdapter().slotLoader = slotLoader
    }

    private func addIABTCFToUserDefaults() {
        UserDefaults.standard.set("1", forKey: "IABTCF_gdprApplies")
        UserDefaults.standard.set("CPJ7oH6PJ7oH6EsABBENBkCoAP_AAH_AAA5QHhNf_X_fbXdj-_59__t0eY1fd_r_v-Qzjhfds-8F2L_W9L0X_0E7NF36pq4KuR4ku3bBIQNtHMnUTUmxaolVrTPsak2Mr6NKJ7LkmnsZe0dYGHtfn91S-ZKZ7_7v_9f73z__vf9979_3P___3_v_7___-____f97_98DwmL_jdvtruxvH403j26NEasq_lP1fAZxwji0beATF_LelYDXqCdgC7dUVYFXI8SWbsAkIGEgCTiIqTYsESqlohkEAIEVcGEEJlyTC2MvKAsADSHx8QoJAlM8vc3kqO94patVs--9-4Tjf_644nXpfh36X_9_OW1_6OAA.f_gAAAAAAAA", forKey: "IABTCF_TCString")
        UserDefaults.standard.synchronize()
    }
}

class APSSlotLoader: NSObject, FYBAPSSlotLoader {
    static let appKey = "6a1ab78a-1f26-405b-ab51-94a6edb7b952"

    override init() {
        super.init()
        DTBAds.sharedInstance().setAppKey(APSSlotLoader.appKey)
    }

    func loadAPSBannerSlot(_ slotUUID: String, width: Int, height: Int) {
        print("loadAPSBannerSlot: \(slotUUID), width: \(width), height: \(height)")
        let loader = DTBAdLoader()
        guard let size = DTBAdSize(bannerAdSizeWithWidth: width, height: height, andSlotUUID: slotUUID) else {
            print("Failed to create DTBAdSize object: (width: \(width), height: \(height), andSlotUUID: \(slotUUID))")
            return
        }
        loader.setAdSizes([size])
        loader.loadAd(self)
    }

    func loadAPSInterstitialSlot(_ slotUUID: String) {
        let loader = DTBAdLoader()
        guard let size = DTBAdSize(interstitialAdSizeWithSlotUUID: slotUUID) else {
            print("Failed to create interstitial DTBAdSize for slotUUID: \(slotUUID))")
            return
        }
        loader.setAdSizes([size])
        loader.loadAd(self)
    }

    func loadAPSRewardedSlot(_ slotUUID: String) {
        let loader = DTBAdLoader()
        guard let size = DTBAdSize(videoAdSizeWithSlotUUID: slotUUID) else {
            print("Failed to create video DTBAdSize for slotUUID: \(slotUUID))")
            return
        }
        loader.setAdSizes([size])
        loader.loadAd(self)
    }

}

extension APSSlotLoader: DTBAdCallback {
    func onSuccess(_ adResponse: DTBAdResponse!) {
        print("[APS] onSuccess: \(String(describing: adResponse.adSize().slotUUID))")
        FairBid.apsAdapter().setBidInfo(adResponse.bidInfo(),
                                        encodedPricePoint: adResponse.amznSlots(),
                                        slotUUID: adResponse.adSize().slotUUID)
    }

    func onFailure(_ error: DTBAdError) {
        print("[APS] onFailure: Amazon APS error: \(error)")
    }
}
