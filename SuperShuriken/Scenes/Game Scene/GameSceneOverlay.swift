//
//  GameSceneOverlay.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/6/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit

class GameSceneOverlay: UIView {
    lazy var scoreLabel = OverlayLabel(text: "Score")
    
    lazy var staminaBar = StaminaBar()
    
    lazy var nextLevelLabel = OverlayLabel(text: "GET READY FOR NEXT LEVEL", alpha: 0, textColor: .white)
    
    lazy var countDownView = CountdownView()

    
    init() {
        super.init(frame: .zero)
        
        addSubview(nextLevelLabel)
        nextLevelLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.right.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        addSubview(staminaBar)
        staminaBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        addSubview(countDownView)
        countDownView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class OverlayLabel: UILabel {
    init(text: String, alpha: CGFloat = 1, textColor: UIColor = .black) {
        super.init(frame: .zero)
        
        self.text = text
        self.alpha = alpha
        font = UIFont.systemFont(ofSize: 30, weight: .bold)
        self.textColor = textColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
