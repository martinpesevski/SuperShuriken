//
//  ShurikenDetailView.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 9/28/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol ShurikenDetailDelegate: class {
    func didCloseDetailVC()
}

class ShurikenDetailViewController: UIViewController, adMobRewardedVideoDelegate, UIGestureRecognizerDelegate {
    
    var shuriken: Shuriken
    weak var delegate: ShurikenDetailDelegate?
    
    lazy var imageView = UIImageView()
    lazy var damageLabel = UILabel("Damage: ", textColor: .black)
    lazy var damageNumberLabel = UILabel(textColor: .black)
    lazy var descriptionLabel = UILabel("Watch a video to permanently unlock this shuriken", textColor: .black)
    lazy var damageStack = UIStackView(views: [damageLabel, damageNumberLabel], axis: .horizontal)
    lazy var damageContainer: UIView = {
        let view = UIView()
        view.addSubview(damageStack)
        damageNumberLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        damageStack.snp.makeConstraints { make in make.edges.equalToSuperview() }
        return view
    }()
    lazy var selectButton = UIButton(title: "Equip", titleColor: .black, target: self, selector: #selector(onEquip))
    lazy var unlockButton = UIButton(title: "Unlock", titleColor: .black, target: self, selector: #selector(onWatch))
    lazy var cancelButton = UIButton(title: "Cancel", titleColor: .black, target: self, selector: #selector(onCancel))
    lazy var buttonStack: UIStackView = {
        let view = UIStackView(views: [selectButton, unlockButton, cancelButton], axis: .horizontal, spacing: 70)
        view.distribution = .equalCentering
        return view
    }()
    lazy var content: UIStackView = {
        let stack = UIStackView(views: [imageView, damageContainer, descriptionLabel, buttonStack], axis: .vertical, spacing: 15,
                                layoutMargins: UIEdgeInsets(top: 50, left: 30, bottom: 10, right: 30))
        stack.alignment = .center
        stack.distribution = .equalCentering
        return stack
    }()
    lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.layer.cornerRadius = 10
        view.addSubview(content)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.8
        view.isExclusiveTouch = true
        return view
    }()
    let minimum = min(3, 5)
    
    init(shuriken: Shuriken) {
        self.shuriken = shuriken
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onCancel))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        view.alpha = 0
        imageView.image = shuriken.image
        damageNumberLabel.text = "\(shuriken.damage)"
        
        selectButton.isHidden = !shuriken.isUnlocked
        unlockButton.isHidden = shuriken.isUnlocked
        descriptionLabel.isHidden = shuriken.isUnlocked
        
        view.addSubview(container)
        content.snp.makeConstraints { make in make.edges.equalToSuperview() }
        container.snp.makeConstraints { make in
            make.top.equalTo(view.snp_bottom)
            make.centerX.equalToSuperview()
        }
        view.layoutIfNeeded()
        
        app.adsManager.rewardedVideoDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.alpha = 1
        }) { [weak self] _ in
            self?.animateIn()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
    
    func animateIn() {
        container.snp.remakeConstraints { make in make.center.equalToSuperview() }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0, options: .curveEaseOut, animations: { [weak self] in
                        self?.view.layoutIfNeeded()
        })
    }
    
    func animateOut(completion: @escaping () -> () = {}) {
        container.snp.remakeConstraints { make in
            make.top.equalTo(view.snp_bottom)
            make.centerX.equalToSuperview()
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0, options: .curveEaseOut, animations: { [weak self] in
                        self?.view.alpha = 0
                        self?.view.layoutIfNeeded()
            }, completion: { _ in
                completion()
        })
    }
    
    @objc func onEquip() {
        app.global.selectedPlayerShuriken = shuriken
        dismiss(animated: false) { [weak self] in self?.delegate?.didCloseDetailVC() }
    }
    
    @objc func onCancel() {
        animateOut { [weak self] in
            self?.dismiss(animated: false) { [weak self] in
                self?.delegate?.didCloseDetailVC()
            }
        }
    }
    
    @objc func onWatch() {
        guard !shuriken.isUnlocked else { return }
        app.global.selectedPlayerShuriken = shuriken
        app.adsManager.showRewardedVideo()
    }
    
    func didEarnReward(_ reward: GADAdReward) {
        app.global.selectedPlayerShuriken.unlock()
        app.global.selectedPlayerShuriken = shuriken
    }
    
    func didDismiss() {
        guard shuriken.isUnlocked else { return }
        dismiss(animated: false) { [weak self] in self?.delegate?.didCloseDetailVC() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
