//
//  MenuButton.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 4/24/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SnapKit

class MenuButton: UIButton {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.setBackgroundImage(UIImage(named: "ic_button"), for: .normal)
        self.setBackgroundImage(UIImage(named: "ic_button_clicked"), for: .highlighted)
        self.titleLabel?.font = (UIFont.systemFont(ofSize: 20))
        self.setTitleColor(.white, for: .normal)
        
        snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(50)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
