//
//  SystemMessageView.swift
//  TogglDesktop
//
//  Created by Nghia Tran on 3/1/19.
//  Copyright © 2019 Alari. All rights reserved.
//

import Cocoa

final class SystemMessageView: NSView {

    // MARK: OUTLET
    
    @IBOutlet weak var iconContainerView: NSBox!
    @IBOutlet weak var iconBtn: NSButton!
    private var floatingViewLeftConstraint: NSLayoutConstraint!
    private lazy var floatingView: FloatingErrorView = {
        return FloatingErrorView.xibView()
    }()

    // MARK: Variables

    fileprivate var payload: SystemMessage.Payload?

    // MARK: Init

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)

        initFloatingView()
        floatingView.onClose = {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.handleClosing()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        initCommon()
    }

    @objc class func initFromXib() -> SystemMessageView {
        return SystemMessageView.xibView()
    }

    // MARK: Public

    @objc func registerToSystemMessage() {
        SystemMessage.shared.register(for: self)
    }

    @IBAction func iconOnTap(_ sender: Any) {
        floatingView.isHidden = false
        iconContainerView.isHidden = false
        iconContainerView.alphaValue = 1.0
        floatingView.alphaValue = 0.0
        floatingViewLeftConstraint.constant = -self.frame.width

        NSAnimationContext.runAnimationGroup({[weak self] (context) in
            guard let strongSelf = self else { return }

            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)

            // Animate
            strongSelf.iconContainerView.animator().alphaValue = 0
            strongSelf.floatingView.animator().alphaValue = 1
            strongSelf.floatingViewLeftConstraint.animator().constant = 0

        }, completionHandler: {[weak self] in
            guard let strongSelf = self else { return }
            strongSelf.iconContainerView.isHidden = true
        })
    }
}

// MARK: SystemMessagePresentable

extension SystemMessageView: SystemMessagePresentable {

    func present(_ payload: SystemMessage.Payload) {

        self.payload = payload
        isHidden = false
        floatingView.isHidden = false
        iconContainerView.isHidden = true
        self.superview?.bringSubviewToFront(self)

        // Stop all animation
        stopAllAnimations()

        // handle icon
        switch payload.mode {
        case .syncing:
            iconContainerView.spinClockwise(timeToRotate: 1.0)
            iconBtn.image = NSImage(named: NSImage.Name("spinner-icon"))
        case .error,
             .information:
            iconBtn.image = nil
        case .offline:
            iconBtn.image = NSImage(named: NSImage.Name("offline-icon"))
        }

        // Floating view
        floatingView.present(payload)
    }

    func dismiss(_ payload: SystemMessage.Payload) {
        guard let currentPayload = self.payload else { return }

        // Only dismiss if the payload is matched with the current
        // It presents to dismiss by accidently
        guard currentPayload.mode == payload.mode else { return }

        stopAllAnimations()
        isHidden = true
    }

    private func stopAllAnimations() {
        iconContainerView.stopAnimations()
    }
}

// MARK: Private

extension SystemMessageView {

    fileprivate func initCommon() {
        wantsLayer = true
        layer?.masksToBounds = false
        iconContainerView.applyShadow()
        iconContainerView.applyBorder(cornerRadius: 13)
        floatingView.wantsLayer = true
    }

    fileprivate func initFloatingView() {
        self.addSubview(floatingView)
        floatingView.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: self,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: floatingView,
                                     attribute: .top,
                                     multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: self,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: floatingView,
                                      attribute: .left,
                                      multiplier: 1.0, constant: 0)
        let width = NSLayoutConstraint(item: floatingView,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: 240.0)
        let bottom = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: floatingView,
                                        attribute: .bottom,
                                        multiplier: 1.0, constant: 10)
        floatingViewLeftConstraint = left
        addConstraints([top, left, width, bottom])
    }

    fileprivate func handleClosing() {
        guard let payload = payload else { return }
        switch payload.mode {
        case .error,
             .information:
            // Hide all, because we don't have circle icon for information
            isHidden = true

        case .offline, .syncing:
            // Hide floating view
            // Then presenting the icon btn
            floatingView.isHidden = false
            iconContainerView.isHidden = false
            iconContainerView.alphaValue = 0.0
            floatingView.alphaValue = 1.0
            floatingViewLeftConstraint.constant = 0

            NSAnimationContext.runAnimationGroup({[weak self] (context) in
                guard let strongSelf = self else { return }

                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)

                // Animate
                strongSelf.iconContainerView.animator().alphaValue = 1.0
                strongSelf.floatingView.animator().alphaValue = 0
                strongSelf.floatingViewLeftConstraint.animator().constant = -strongSelf.frame.width

            }, completionHandler: {[weak self] in
                guard let strongSelf = self else { return }
                strongSelf.floatingView.isHidden = true
            })
        }
    }
}
