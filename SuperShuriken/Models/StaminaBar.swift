//
//  StaminaBarNode.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 2/10/19.
//  Copyright © 2019 MP. All rights reserved.
//

import UIKit
import SnapKit

let staminaWidth = 140.0
let maxStamina = 10.0

class StaminaBar: UIView {
    let red = 1.0
    let green = 0.0
    let blue = 0.0
    
    let finalRed = 0.0
    let finalGreen = 1.0
    let finalBlue = 0.0
    
    var isExhausted = false
    private var staminaBarView: UIView = {
        let staminaBar = UIView()
        staminaBar.backgroundColor = .green
        return staminaBar
    }()
    
    private var staminaBarRightConstraint: Constraint?
    private var stamina = maxStamina
    private lazy var timer = Timer(timeInterval: 0.03, repeats: true) { timer in
        self.increaseStamina()
    }

    init() {
        super.init(frame: .zero)
        isExhausted = false
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        
        snp.makeConstraints { make in
            make.width.equalTo(150)
            make.height.equalTo(27)
        }
        
        addSubview(staminaBarView)
        staminaBarView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(5)
            staminaBarRightConstraint = make.right.equalToSuperview().inset(5).constraint
            make.bottom.equalToSuperview().inset(5)
        }
        
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didShoot() {
        if stamina <= 0 {
            return
        }
        
        stamina -= 0.4
        if stamina < 0 {
            stamina = 0
            handleExhausted()
        }
        
        updateBar()
    }
    
    func increaseStamina(){
        guard stamina < 10, !isExhausted else { return }
        stamina += 0.1
        if stamina > 10 { stamina = 10 }
        
        updateBar()
    }
    
    func handleExhausted(){
        isExhausted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [unowned self] in
            self.isExhausted = false
        }
    }
    
    func updateBar() {
        staminaBarRightConstraint?.update(inset: max((10 - stamina) * 14, 5))
        let progress = stamina/10
        
        let newRed = (1 - progress) * red + progress * finalRed
        let newGreen = (1 - progress) * green + progress * finalGreen
        let newBlue = (1 - progress) * blue + progress * finalBlue

        staminaBarView.backgroundColor = UIColor(red: CGFloat(newRed), green: CGFloat(newGreen), blue: CGFloat(newBlue), alpha: 1)
    }
}
