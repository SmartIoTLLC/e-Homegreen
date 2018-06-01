//
//  AudioPlayerBar.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 5/31/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let buttonSize: CGSize = CGSize(width: 42, height: 33)
    static let radioBottomPadding: CGFloat = 25
    static let radioButtonSidePadding: CGFloat = 8
    static let radioTitleLabelHeight: CGFloat = 30
}

class AudioPlayerBar: UIView {
    
    private let radioTitleLabel: UILabel = UILabel()
    private let pauseButton: UIButton = UIButton()
    private let stopButton: UIButton = UIButton()
    private let playButton: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor  = UIColor(cgColor: Colors.DarkGray)
        
        addTitleLabel()
        addPauseButton()
        addPlayButton()
        addStopButton()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor  = UIColor(cgColor: Colors.DarkGray)
        
        addTitleLabel()
        addPauseButton()
        addPlayButton()
        addStopButton()
        
        setupConstraints()
    }
    
    private func addTitleLabel() {
        radioTitleLabel.textColor = UIColor.white
        radioTitleLabel.font      = .tahoma(size: 15)
        
        addSubview(radioTitleLabel)
    }
    
    private func addPauseButton() {
        pauseButton.setImage(#imageLiteral(resourceName: "audio_pause"), for: UIControlState())
        pauseButton.backgroundColor        = UIColor.darkGray
        pauseButton.imageView?.contentMode = .scaleAspectFit
        pauseButton.layer.cornerRadius     = 3
        
        addSubview(pauseButton)
    }
    
    private func addStopButton() {
        stopButton.setImage(#imageLiteral(resourceName: "audio_stop"), for: UIControlState())
        stopButton.backgroundColor        = UIColor.darkGray
        stopButton.layer.cornerRadius     = 3
        stopButton.imageView?.contentMode = .scaleAspectFit
        
        addSubview(stopButton)
    }
    
    private func addPlayButton() {
        playButton.setImage(#imageLiteral(resourceName: "audio_play"), for: UIControlState())
        playButton.backgroundColor        = UIColor.darkGray
        playButton.layer.cornerRadius     = 3
        playButton.imageView?.contentMode = .scaleAspectFit
        
        addSubview(playButton)
    }
    
    private func setupConstraints() {
        radioTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(LocalConstants.radioButtonSidePadding)
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.height.equalTo(LocalConstants.radioTitleLabelHeight)
        }
        
        pauseButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(LocalConstants.radioBottomPadding)
            make.width.equalTo(LocalConstants.buttonSize.width)
            make.height.equalTo(LocalConstants.buttonSize.height)
            make.centerX.equalToSuperview()
        }
        
        stopButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(LocalConstants.radioBottomPadding)
            make.trailing.equalTo(pauseButton.snp.leading).inset(-LocalConstants.radioButtonSidePadding)
            make.width.equalTo(LocalConstants.buttonSize.width)
            make.height.equalTo(LocalConstants.buttonSize.height)
        }
        
        playButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(LocalConstants.radioBottomPadding)
            make.leading.equalTo(pauseButton.snp.trailing).offset(LocalConstants.radioButtonSidePadding)
            make.width.equalTo(LocalConstants.buttonSize.width)
            make.height.equalTo(LocalConstants.buttonSize.height)
        }
    }
    
    func setTitle(with text: String?) {
        radioTitleLabel.text = text
    }
    
    func setStopAction(with action: @escaping () -> () ) {
        stopButton.addTap {
            action()
        }
    }
    
    func setPlayAction(with action: @escaping () -> () ) {
        playButton.addTap {
            action()
        }
    }
    
    func setPauseAction(with action: @escaping () -> () ) {
        pauseButton.addTap {
            action()
        }
    }
}
