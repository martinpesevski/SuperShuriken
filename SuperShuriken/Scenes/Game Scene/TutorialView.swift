//
//  TutorialView.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/14/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit

protocol TutorialDelegate: class {
    func didComplete()
}

class TutorialView: UIView {
    weak var delegate: TutorialDelegate?
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    lazy var button: UIButton = {
        let but = UIButton()
        but.backgroundColor = .clear
        but.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        
        return but
    }()
    
    let hintsArray = ["Touch and drag on the left side of the screen to move the hero",
    "Tap on the right side of the screen to throw shurikens",
    "Throwing shurikens depletes your stamina.\nIf your stamina reaches zero, you will not be able to shoot until it starts recharging",
    "Some enemies have armor and can only be destroyed in close combat",
    "Some enemies are too big, and can only be destroyed from range",
    "Bosses present a bigger challenge than regular enemies, and are more difficult to destroy"]
    
    var hintIndex = 0
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(50)
        }
        
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        showNextHint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onTap() {
        showNextHint()
    }
    
    func showNextHint() {
        guard hintIndex < hintsArray.count else {
            delegate?.didComplete()
            self.fadeOut()
            self.removeFromSuperview()
            Global.sharedInstance.hasFinishedTutorial = true
            return
        }
        
        textLabel.text = hintsArray[safe: hintIndex]
        hintIndex += 1
    }
}
