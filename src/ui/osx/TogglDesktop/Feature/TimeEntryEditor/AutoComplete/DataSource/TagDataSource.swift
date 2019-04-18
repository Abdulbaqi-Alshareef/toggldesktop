//
//  TagDataSource.swift
//  TogglDesktop
//
//  Created by Nghia Tran on 4/5/19.
//  Copyright © 2019 Alari. All rights reserved.
//

import Foundation

final class TagDataSource: AutoCompleteViewDataSource {

    private struct Constants {

        static let CellID = NSUserInterfaceItemIdentifier("TagCellView")
        static let CellNibName = NSNib.Name("TagCellView")
        static let ClientEmptyCellID = NSUserInterfaceItemIdentifier("NoClientCellView")
        static let ClientEmptyIDNibName = NSNib.Name("NoClientCellView")
    }

    // MARK: Variables

    private(set) var selectedTags: [Tag] = []

    // MARK: Override

    override func setup(with textField: AutoCompleteTextField) {
        super.setup(with: textField)
        tableView.allowsMultipleSelection = true
        autoCompleteView.setCreateButtonSectionHidden(true)
    }

    override func registerCustomeCells() {
        tableView.register(NSNib(nibNamed: Constants.CellNibName, bundle: nil),
                           forIdentifier: Constants.CellID)
        tableView.register(NSNib(nibNamed: Constants.ClientEmptyIDNibName, bundle: nil),
                           forIdentifier: Constants.ClientEmptyCellID)
    }

    override func filter(with text: String) {

        // show all
        if text.isEmpty {
            render(with: TagStorage.shared.tags)
            return
        }

        // Filter
        let filterItems = TagStorage.shared.filter(with: text)
        render(with: filterItems)
    }

    override func render(with items: [Any]) {
        super.render(with: items)

        reSelectSelectedTags()

        // Hide create if it's has content
        if let first = items.first as? Tag, first.isEmptyTag {
            autoCompleteView.setCreateButtonSectionHidden(false)
            autoCompleteView.updateTitleForCreateButton(with: "Create new tag \"\(textField.stringValue)\"")
        } else {
            autoCompleteView.setCreateButtonSectionHidden(true)
        }
    }

    func updateSelectedTags(_ tags: [Tag]) {
        self.selectedTags = tags
        reSelectSelectedTags()
    }

    private func reSelectSelectedTags() {
        guard let tags = items as? [Tag] else {
            return
        }

        // Re-select the selected tab
        tableView.deselectAll(nil)

        // Convert selected tag with new index from the list
        let selectedIndexs = tags.enumerated().compactMap { (item) -> IndexSet? in
            if tags.contains(where: { $0.name == item.element.name }) {
                return IndexSet(integer: item.offset)
            }
            return nil
        }

        // Select all selected
        tableView.beginUpdates()
        selectedIndexs.forEach {
            tableView.selectRowIndexes($0, byExtendingSelection: false)
        }
        tableView.endUpdates()
    }
    // MARK: Public

    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = items[row] as! Tag
        if item.isEmptyTag {
            return tableView.makeView(withIdentifier: Constants.ClientEmptyCellID, owner: self) as! NoClientCellView
        }
        let view = tableView.makeView(withIdentifier: Constants.CellID, owner: self) as! TagCellView
        view.render(item)
        return view
    }

    override func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let item = items[row] as! Tag
        if item.isEmptyTag {
            return NoClientCellView.cellHeight
        }
        return TagCellView.cellHeight
    }

    override func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let item = items[row] as! Tag
        if item.isEmptyTag {
            return false
        }
        return true
    }
}
