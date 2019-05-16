//
//  DesciptionTimeEntryStorage.swift
//  TogglDesktop
//
//  Created by Nghia Tran on 5/16/19.
//  Copyright © 2019 Alari. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let DescrptionTimeEntryStorageChangedNotification = Notification.Name("DescrptionTimeEntryStorageChangedNotification")
}

@objcMembers final class DesciptionTimeEntryStorage: NSObject {

    static let shared = DesciptionTimeEntryStorage()

    // MARK: Variables

    private(set) var items: [Any] = []
    private var autoCompleteItems: [AutocompleteItem] = []

    // MARK: Public

    func update(with autoCompleteItems: [AutocompleteItem]) {
        self.autoCompleteItems = autoCompleteItems
        self.items = buildProjectItems(with: autoCompleteItems)
        NotificationCenter.default.post(name: .DescrptionTimeEntryStorageChangedNotification,
                                        object: items)
    }

    func filter(with text: String) -> [Any] {

        // Filter with project lable or client label
        let filters = autoCompleteItems.filter {
            return $0.projectLabel.fuzzySearch(with: text) ||
                $0.clientLabel.fuzzySearch(with: text)
        }

        return buildProjectItems(with: filters)
    }
}

// MARK: Private

extension DesciptionTimeEntryStorage {

    func buildProjectItems(with autoCompleteItems: [AutocompleteItem]) -> [Any] {

        // Get first item
        guard let firstItem = autoCompleteItems.first else {
            return []
        }

        // Process
        var newItems: [Any] = []
        var currentWorkspace = firstItem.workspaceName
        var currentClient = firstItem.clientLabel

        // Append the first workspace and client
        newItems.append(ProjectWorkspaceItem(item: firstItem))
        newItems.append(ProjectHeaderItem(item: firstItem))

        // Append new item or create new client
        for item in autoCompleteItems {
            if item.workspaceName != currentWorkspace {
                newItems.append(ProjectWorkspaceItem(item: firstItem))
                currentWorkspace = item.workspaceName
            }
            if item.clientLabel != currentClient {
                newItems.append(ProjectHeaderItem(item: item))
                currentClient = item.clientLabel
            }
            newItems.append(ProjectContentItem(item: item))
        }

        return newItems
    }
}
