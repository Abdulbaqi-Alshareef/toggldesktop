//
//  EditorViewController.swift
//  TogglDesktop
//
//  Created by Nghia Tran on 3/21/19.
//  Copyright © 2019 Alari. All rights reserved.
//

import Cocoa

final class EditorViewController: NSViewController {

    // MARK: OUTLET

    @IBOutlet weak var projectBox: NSBox!
    @IBOutlet weak var projectTextField: ProjectAutoCompleteTextField!
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var tagTextField: TagAutoCompleteTextField!
    @IBOutlet weak var billableCheckBox: NSButton!
    @IBOutlet weak var projectDotImageView: DotImageView!
    @IBOutlet weak var closeBtn: CursorButton!
    @IBOutlet weak var deleteBtn: NSButton!
    
    @IBOutlet weak var tagAutoCompleteContainerView: NSBox!
    @IBOutlet weak var tagStackView: NSStackView!
    @IBOutlet weak var tagAddButton: NSButton!

    // MARK: Variables

    var timeEntry: TimeEntryViewItem! {
        didSet {
            fillData()
        }
    }
    private var selectedProjectItem: ProjectContentItem?
    private lazy var projectDatasource = ProjectDataSource(items: ProjectStorage.shared.items,
                                                           updateNotificationName: .ProjectStorageChangedNotification)
    
    // MARK: View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initCommon()
        initDatasource()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        view.window?.makeFirstResponder(descriptionTextField)
        updateNextKeyViews()
    }
    
    @IBAction func closeBtnOnTap(_ sender: Any) {
        DesktopLibraryBridge.shared().togglEditor()
    }

    @IBAction func tagAddButtonOnTap(_ sender: Any) {
        tagAutoCompleteContainerView.isHidden = false
        view.window?.makeFirstResponder(tagTextField)
    }
}

// MARK: Private

extension EditorViewController {

    fileprivate func initCommon() {
        view.wantsLayer = true
        view.layer?.masksToBounds = false
        closeBtn.cursor = .pointingHand

        projectTextField.autoCompleteDelegate = self
        projectTextField.dotImageView = projectDotImageView
        projectTextField.layoutArrowBtn(with: view)

        descriptionTextField.delegate = self
    }

    fileprivate func initDatasource() {
        projectDatasource.delegate = self
        projectDatasource.setup(with: projectTextField)
    }

    fileprivate func fillData() {
        descriptionTextField.stringValue = timeEntry.descriptionName
        billableCheckBox.state = timeEntry.billable ? .on : .off
        projectTextField.setTimeEntry(timeEntry)
    }

    fileprivate func updateNextKeyViews() {
        deleteBtn.nextKeyView = descriptionTextField
    }
}

// MARK: AutoCompleteViewDataSourceDelegate

extension EditorViewController: AutoCompleteViewDataSourceDelegate {

    func autoCompleteSelectionDidChange(sender: AutoCompleteViewDataSource, item: Any) {
        if sender == projectDatasource {
            if let projectItem = item as? ProjectContentItem {
                selectedProjectItem = projectItem
                projectTextField.projectItem = projectItem
                projectTextField.closeSuggestion()

                // Update
                let item = projectItem.item
                let projectGUID = projectTextField.lastProjectGUID ?? ""
                DesktopLibraryBridge.shared().setProjectForTimeEntryWithGUID(timeEntry.guid,
                                                                             taskID: item.taskID,
                                                                             projectID: item.projectID,
                                                                             projectGUID: projectGUID)
            }
        }
    }
}

extension EditorViewController: NSTextFieldDelegate {

    func controlTextDidEndEditing(_ obj: Notification) {
        guard let timeEntry = timeEntry else { return }
        guard timeEntry.descriptionName != descriptionTextField.stringValue else { return }
        let name = descriptionTextField.stringValue
        let guid = timeEntry.guid!
        DesktopLibraryBridge.shared().updateTimeEntry(withDescription: name, guid: guid)
    }
}

// MARK: AutoCompleteTextFieldDelegate

extension EditorViewController: AutoCompleteTextFieldDelegate {

    func autoCompleteDidTapOnCreateButton(_ sender: AutoCompleteTextField) {

    }

    func shouldClearCurrentSelection(_ sender: AutoCompleteTextField) {
        if sender == projectTextField {
            selectedProjectItem = nil
            projectTextField.projectItem = nil
            projectTextField.closeSuggestion()

            // Update
            DesktopLibraryBridge.shared().setProjectForTimeEntryWithGUID(timeEntry.guid,
                                                                         taskID: 0,
                                                                         projectID: 0,
                                                                         projectGUID: "")
        }
    }
}