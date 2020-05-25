//
//  ColorViewItem.swift
//  TogglDesktop
//
//  Created by Nghia Tran on 3/28/19.
//  Copyright © 2019 Alari. All rights reserved.
//

import Cocoa

final class ColorViewItem: NSCollectionViewItem {

    // MARK: OUTLET

    @IBOutlet weak var boxView: NSBox!
    @IBOutlet weak var colorCheckImageView: NSImageView!

    // MARK: View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initCommon()
    }

    // MARK: Public

    func render(_ color: ProjectColor) {
        guard let color = ConvertHexColor.hexCode(toNSColor: color.hex) else {
            return
        }
        boxView.fillColor = color.getAdaptiveColorForShape()
    }

    override var isSelected: Bool {
        didSet {
            colorCheckImageView.isHidden = !isSelected
        }
    }

    private func initCommon() {

    }
}
