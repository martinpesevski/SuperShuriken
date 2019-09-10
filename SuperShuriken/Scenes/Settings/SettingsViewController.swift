//
//  SettingsViewController.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/25/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMobileAds

class SettingsViewController: UIViewController, ToggleViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, adMobRewardedVideoDelegate {
    
    var selectedShuriken = Global.sharedInstance.selectedPlayerShuriken
    let storeManager = StoreManager.shared
    
    let backgroundImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "splashScreen"))
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    lazy var shurikenCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.register(ShurikenCell.self, forCellWithReuseIdentifier: "shurikenCell")
        collection.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        collection.layer.cornerRadius = 10
        collection.layer.borderWidth = 5
        collection.layer.borderColor = UIColor.gray.cgColor
        collection.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collection.alpha = 0
        collection.dataSource = self
        collection.delegate = self
        
        return collection
    }()
    
    lazy var menuButton: MenuButton = {
        let button = MenuButton()
        button.setTitle("Menu", for: .normal)
        button.addTarget(self, action: #selector(onMenu), for: .touchUpInside)
        
        return button
    }()
    
    lazy var disableAdsButton: MenuButton = {
        let button = MenuButton()
        let purchased = storeManager.isPurchased(.disableAds)
        button.setTitle("Disable ads", for: .normal)
        button.setTitleColor(purchased ? .gray : .white, for: .normal)
        button.isUserInteractionEnabled = !purchased
        button.addTarget(self, action: #selector(onDisableAds), for: .touchUpInside)
        return button
    }()
    
    lazy var soundToggle: ToggleView = {
        let togView = ToggleView(title: "Enable sound")
        togView.toggle.isOn = Global.sharedInstance.isSoundOn
        togView.delegate = self
        
        return togView
    }()
    
    lazy var container: UIStackView = {
       let stack = UIStackView(arrangedSubviews: [menuButton, disableAdsButton, soundToggle])
        stack.spacing = 20
        stack.axis = .vertical
        
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundImageView)
        view.addSubview(container)
        view.addSubview(shurikenCollectionView)
        
        storeManager.purchaseStatusBlock = { [weak self] type in
            guard let self = self else { return }
            
            self.disableAdsButton.setLoading(false)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        container.snp.makeConstraints { make in
            make.right.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        shurikenCollectionView.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.bottom.right.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(120)
        }
        shurikenCollectionView.fadeIn()
        
        AdsManager.shared.rewardedVideoDelegate = self
    }
    
    func onToggle(sender: ToggleView, selected: Bool) {
        switch sender {
        case soundToggle:
            Global.sharedInstance.isSoundOn = selected
        default:
            break
        }
    }
    
    @objc func onMenu(){
        dismiss(animated: true)
    }
    
    @objc func onDisableAds() {
        storeManager.purchase(index: 0)
        disableAdsButton.setLoading(true)
    }
    
    //MARK: - collectionView
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shurikenCell", for: indexPath) as! ShurikenCell
        
        cell.setup(shuriken: Shuriken(rawValue: indexPath.item) ?? .basic)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let shuriken = Shuriken(rawValue: indexPath.item) else {
            return
        }

        if !shuriken.isUnlocked {
            selectedShuriken = shuriken
            AdsManager.shared.showRewardedVideo()
            return
        }
        
        selectShuriken(shuriken)
    }
    
    func selectShuriken(_ shuriken: Shuriken) {
        Global.sharedInstance.selectedPlayerShuriken = shuriken
        shurikenCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Shuriken.count
    }
    
    func didEarnReward(_ reward: GADAdReward) {
        selectedShuriken.unlock()
        selectShuriken(selectedShuriken)
    }
}
