//
//  SettingsViewController.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/25/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SnapKit

class SettingsViewController: UIViewController, ToggleViewDelegate {
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
        return collection
    }()
    
    lazy var menuButton: MenuButton = {
        let button = MenuButton()
        button.setTitle("Menu", for: .normal)
        button.addTarget(self, action: #selector(onMenu), for: .touchUpInside)
        
        return button
    }()
    
    lazy var adsToggle: ToggleView = {
        let togView = ToggleView(title: "Ads enabled")
        togView.delegate = self
        
        return togView
    }()
    
    lazy var soundToggle: ToggleView = {
        let togView = ToggleView(title: "Enable sound")
        togView.delegate = self
        
        return togView
    }()
    
    lazy var container: UIStackView = {
       let stack = UIStackView(arrangedSubviews: [menuButton, adsToggle, soundToggle])
        stack.spacing = 20
        stack.axis = .vertical
        
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundImageView)
        view.addSubview(container)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        container.snp.makeConstraints { make in
            make.right.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
    }
    
    func onToggle(sender: ToggleView, selected: Bool) {
        switch sender {
        case adsToggle:
            selected ? AdsManager.sharedInstance.showAds() : AdsManager.sharedInstance.removeAds()
        case soundToggle:
            Global.sharedInstance.isSoundOn = selected
        default:
            break
        }
    }
    
    @objc func onMenu(){
        dismiss(animated: true)
    }
}     
