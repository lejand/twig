//
//  SidebarViewController+Extension.swift
//  Twig
//
//  Created by Luka Kerr on 24/6/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Cocoa

extension SidebarViewController: NSOutlineViewDataSource {

  // Number of items in the sidebar
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item as? FileSystemItem else { return items.count }
    return item.getNumberOfChildren()
  }

  // Items to be added to sidebar
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    guard let item = item as? FileSystemItem else { return items[index] }
    return item.getChild(at: index)
  }

  // Whether rows are expandable by an arrow
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    guard let item = item as? FileSystemItem else { return false }
    return item.getNumberOfChildren() != 0
  }

  // Height of each row
  func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
    return 30.0
  }

  // When a row is clicked on should it be selected
  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    guard let item = item as? FileSystemItem else { return false }
    return !item.isDirectory
  }

  // When a row is selected
  func outlineViewSelectionDidChange(_ notification: Notification) {
    guard
      let outlineView = notification.object as? NSOutlineView,
      let doc = outlineView.item(atRow: outlineView.selectedRow) as? FileSystemItem,
      doc.getNumberOfChildren() == 0,
      let window = self.view.window?.windowController as? WindowController
    else { return }

    setRowColour(outlineView)
    window.changeDocument(file: doc.fileUrl)
  }

  func setRowColour(_ outlineView: NSOutlineView) {
    let rows = IndexSet(integersIn: 0..<outlineView.numberOfRows)
    let rowViews = rows.compactMap { outlineView.rowView(atRow: $0, makeIfNecessary: false) }

    // Iterate over each row in the outlineView
    for rowView in rowViews {
      rowView.backgroundColor = rowView.isSelected ? .secondarySelectedControlColor : .clear
    }
  }

  // Remove default selection colour
  func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
    rowView.selectionHighlightStyle = .none

    guard
      let window = self.view.window?.windowController as? WindowController,
      let doc = window.document as? NSDocument
    else { return }

    for (index, item) in items.enumerated()
      where index == row && item.fullPath == doc.fileURL?.relativePath {
        rowView.isSelected = true
    }

    setRowColour(outlineView)
  }

}

extension SidebarViewController: NSOutlineViewDelegate {

  // Create a cell given an item and set its properties
  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    guard let item = item as? FileSystemItem else { return nil }

    let view = outlineView.makeView(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"),
      owner: self
    ) as? NSTableCellView
    view?.textField?.stringValue = item.getName()

    if item.isDirectory {
      view?.imageView?.image = NSImage(named: "Folder")
    } else {
      view?.imageView?.image = NSImage(named: "Document")
    }

    return view
  }

}
