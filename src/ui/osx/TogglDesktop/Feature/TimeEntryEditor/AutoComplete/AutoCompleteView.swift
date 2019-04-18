//
//  AutoCompleteView.swift
//  TogglDesktop
//
//  Created by Nghia Tran on 3/25/19.
//  Copyright © 2019 Alari. All rights reserved.
//

import Cocoa

final class AutoCompleteViewWindow: NSWindow {

    // MARK: Private

    private var topPadding: CGFloat = 5.0
    var isSeparateWindow = true
    override var canBecomeMain: Bool {
        return true
    }
    override var canBecomeKey: Bool {
        return true
    }

    // MARK: Init

    init(view: NSView) {
        super.init(contentRect: view.bounds,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: true)
        contentView = view
        hasShadow = true
        backgroundColor = NSColor.clear
        isOpaque = false
        setContentBorderThickness(0, for: NSRectEdge(rawValue: 0)!)
    }

    func layoutFrame(with textField: NSTextField, height: CGFloat) {
        guard let window = textField.window else { return }
        var height = height
        let size = textField.frame.size

        // Convert
        var location = CGPoint.zero
        let point = textField.superview!.convert(textField.frame.origin, to: nil)
        if #available(OSX 10.12, *) {
            location = window.convertPoint(toScreen: point)
        } else {
            // Fallback on earlier versions
        }
        if isSeparateWindow {
            location.y -= topPadding
        } else {
            location.y -= -30.0
            height += 30.0
        }

        setFrame(CGRect(x: 0, y: 0, width: size.width, height: height), display: false)
        setFrameTopLeftPoint(location)
    }

    func cancel() {
        parent?.removeChildWindow(self)
        orderOut(nil)
    }
}

protocol AutoCompleteViewDelegate: class {

    func didTapOnCreateButton()
}

final class AutoCompleteView: NSView {

    // MARK: OUTLET

    @IBOutlet weak var tableView: KeyboardTableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var createNewItemBtn: CursorButton!
    @IBOutlet weak var createNewItemContainerView: NSBox!
    @IBOutlet weak var horizontalLine: NSBox!
    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet weak var placeholderBox: NSView!
    @IBOutlet weak var placeholderBoxContainerView: NSView!

    // MARK: Variables

    weak var delegate: AutoCompleteViewDelegate?
    private weak var dataSource: AutoCompleteViewDataSource?

    // MARK: Public

    override func awakeFromNib() {
        super.awakeFromNib()

        initCommon()
    }

    func prepare(with dataSource: AutoCompleteViewDataSource) {
        self.dataSource = dataSource
    }

    func filter(with text: String) {
        dataSource?.filter(with: text)
    }

    func update(height: CGFloat) {
        tableViewHeight.constant = height
    }

    func setCreateButtonSectionHidden(_ isHidden: Bool) {
        horizontalLine.isHidden = isHidden
        createNewItemContainerView.isHidden = isHidden
    }

    func updateTitleForCreateButton(with text: String) {
        createNewItemBtn.title = text
    }

    @IBAction func createNewItemOnTap(_ sender: Any) {
        delegate?.didTapOnCreateButton()
    }
}

// MARK: Private

extension AutoCompleteView {

    fileprivate func initCommon() {
        stackView.wantsLayer = true
        stackView.layer?.masksToBounds = true
        stackView.layer?.cornerRadius = 8
        placeholderBox.isHidden = true
        createNewItemBtn.cursor = .pointingHand
        tableView.keyDidDownOnPress = {[weak self] key -> Bool in
            guard let strongSelf = self else { return false }
            switch key {
            case .enter,
                 .returnKey:
                strongSelf.dataSource?.selectSelectedRow()
                return true
            case .tab:
                // Only focus to create button if the view is expaned
                if let textField = strongSelf.dataSource?.textField, textField.state == .expand {
                    strongSelf.window?.makeKeyAndOrderFront(nil)
                    strongSelf.window?.makeFirstResponder(strongSelf.createNewItemBtn)
                    return true
                }
            default:
                return false
            }
            return false
        }
        tableView.clickedOnRow = {[weak self] clickedRow in
            self?.dataSource?.selectRow(at: clickedRow)
        }
    }
}
