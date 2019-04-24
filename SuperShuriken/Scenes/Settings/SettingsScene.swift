//
//  SettingsScene.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 1/14/18.
//  Copyright © 2018 MP. All rights reserved.
//

import SpriteKit
import UIKit

class SettingsScene : SKScene, switchNodeDelegate {
    
    var menuButton : ButtonNode!
    var soundCell : LabelWithSwitchNode!
    var adsCell : LabelWithSwitchNode!
    var shurikensArray : [Shuriken] = [.basic, .straight, .red]
    
    var shurikenCollectionView : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.register(ShurikenCell.self, forCellWithReuseIdentifier: "shurikenCell")
        collection.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        collection.layer.cornerRadius = 10
        collection.layer.borderWidth = 5
        collection.layer.borderColor = UIColor.gray.cgColor
        collection.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collection.alpha = 0
        return collection
    }()

    override func didMove(to view: SKView) {
        guard let soundPlaceholder = childNode(withName: "soundPlaceholder") as? LabelWithSwitchNode,
            let adsPlaceholder = childNode(withName: "adsPlaceholder") as? LabelWithSwitchNode,
            let menuPlaceholder = childNode(withName: "backPlaceholder") as? SKSpriteNode
            else {
            return
        }
        
        shurikenCollectionView.dataSource = self
        shurikenCollectionView.delegate = self
        
        menuButton = ButtonNode.init(normalTexture: SKTexture.init(imageNamed: "ic_button"),
                                     selectedTexture: SKTexture.init(imageNamed: "ic_buttonClicked"),
                                     disabledTexture: nil)
        menuButton.setupWithNode(node: menuPlaceholder)
        menuButton.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(onMenuTap))
        menuButton.setButtonLabel(title: "menu", font: "Chalkduster", fontSize: 20)
        menuButton.zPosition = 2
        
        soundCell = soundPlaceholder
        soundCell.setupWithText(labelText: "Sound")
        soundCell.switchDelegate = self
        soundCell.setSwitch(isOn: Global.sharedInstance.isSoundOn)
        
//        let lockedAssets = Global.sharedInstance.lockedShurikenAssets

        adsCell = adsPlaceholder
        adsCell.setupWithText(labelText: "Enable ads")
        adsCell.switchDelegate = self
        adsCell.setSwitch(isOn: Global.sharedInstance.adsEnabled)
        
        addChild(menuButton)
        scene?.view?.addSubview(shurikenCollectionView)
        
        shurikenCollectionView.snp.makeConstraints { make in
            guard let view = scene?.view else {return}
            
            make.height.equalTo(150)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.5, animations: {
            self.shurikenCollectionView.alpha = 1
        }, completion: nil) 
    }
    
    @objc func onMenuTap() {
        UIView.animate(withDuration: 1, animations: {
            self.shurikenCollectionView.alpha = 0
        }) {  _ in
            self.shurikenCollectionView.removeFromSuperview()
        }
        
        let reveal = SKTransition.fade(withDuration: 1)
        if let scene = MainMenu(fileNamed: "MainMenu") {
            scene.initialize()
            
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    func onSoundTap(isOn: Bool) {
        Global.sharedInstance.isSoundOn = isOn
    }
    
    func onAdsTap(isOn: Bool) {
        isOn ? AdsManager.sharedInstance.showAds() : AdsManager.sharedInstance.removeAds()
    }
    
    func onSwitchTap(isOn: Bool, sender: SKNode) {
        if sender == soundCell {
            onSoundTap(isOn: isOn)
        } else if sender == adsCell {
            onAdsTap(isOn: isOn)
        }
    }
}



extension SettingsScene: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Shuriken.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shurikenCell", for: indexPath) as? ShurikenCell else {
            return UICollectionViewCell()
        }
        
        cell.setup(shuriken: shurikensArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var shuriken = shurikensArray[indexPath.item]
        shuriken.isSelected = true
        collectionView.reloadData()
    }
}
