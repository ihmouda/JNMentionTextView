//
//  JNMentionTextView.swift
//  JNMentionTextView
//
//  Created by JNDisrupter 💡 on 6/17/19.
//

import UIKit

/// Component Values
private struct ComponentValues {
    
    // Default Cell Height
    static let defaultCellHeight: CGFloat = 50.0
}

/// JNMentionEntity
public struct JNMentionEntity {
    
    /// Ranage
    var range: NSRange
    
    /// Symbol
    var symbol: String
    
    /// Pickable Item
    var item: JNMentionPickable

    /**
     Initializer
     - Parameter item: JNMentionEntityPickable Item
     - Parameter symbol: Symbol special character
     */
    init(item: JNMentionPickable, symbol: String) {
        
        self.item = item
        self.symbol = symbol
        self.range = NSRange(location: 0, length: 0)
    }
}

/// JNMentionTextView
open class JNMentionTextView: UITextView {
    
    /// JNMentionAttributeName
    static let JNMentionAttributeName: NSAttributedString.Key = (NSString("JNMENTIONITEM")) as NSAttributedString.Key

    /// Selected Symbol
    var selectedSymbol: String!
    
    /// Selected Symbol Location
    var selectedSymbolLocation: Int!
    
    /// Selected Symbol Attributes
    var selectedSymbolAttributes: [NSAttributedString.Key : Any]!
    
    /// Search String
    var searchString: String!
    
    /// Options
    var options: JNMentionPickerViewOptions!
    
    /// Picker View
    var pickerView: JNMentionPickerView!
    
    /// Mention Delegate
    public weak var mentionDelegate: JNMentionTextViewDelegate?
    
    /// Mention Replacements
    public var mentionReplacements: [String: [NSAttributedString.Key : Any]] = [:]
    
    /// Normal Attributes
    internal var normalAttributes: [NSAttributedString.Key: Any] = [:]
    
    /// Tap Gesture
    var previousOffset: CGPoint = CGPoint.zero
    
    // MARK:- Initializers

    /**
     Initializer
     */
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.initView()
    }
    
    /**
     Initializer
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initView()
    }
    
    /**
     Init View
     */
    private func initView(){
        
        self.selectedSymbol = ""
        self.selectedSymbolLocation = 0
        self.selectedSymbolAttributes = [:]
        self.searchString = ""
        
        self.delegate = self
    }
    
    /**
     Setup
     - Parameter options: JNMentionOptions Object.
     */
    open func setup(options: JNMentionPickerViewOptions) {
        
        // set options
        self.options = options
        
        // init picker view
        self.initPickerView()
        
        // set picker view delegate
        self.pickerView.delegate = self
    }

    /**
     Register Table View Cells
     - Parameter cells: list of Table View Cells.
     */
    open func registerTableViewCell(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        self.pickerView.tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    /**
     Get Mentioned Items
     - Parameter symbol: Symbol string value.
     - Returns [JNMentionEntity]: list of mentioned (JNMentionEntity)
     */
    open func getMentionedItems(for symbol: String) -> [JNMentionEntity] {
        
        var mentionedItems: [JNMentionEntity] = []
        
        self.attributedText.enumerateAttributes(in: NSRange(0..<self.textStorage.length), options: [], using:{ attrs, range, stop in
            
            if let item = (attrs[JNMentionTextView.JNMentionAttributeName] as AnyObject) as? JNMentionEntity, item.symbol == symbol {
                
                var mentionedItem = item
                mentionedItem.range = range
                mentionedItems.append(mentionedItem)
            }
        })
        
        return mentionedItems
    }
    
    /**
     Is In Filter Process
     - Returns Bool: Bool value to indicate if the mention is in filter process.
     */
    func isInFilterProcess() -> Bool {
        return !self.pickerView.isHidden
    }
    
    /**
     Move cursor to
     - Parameter location: Location.
     */
    func moveCursor(to location: Int, completion:(() -> ())? = nil) {
        
        // get cursor position
        if let newPosition = self.position(from: self.beginningOfDocument, offset: location) {
            DispatchQueue.main.async {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
                
                completion?()
            }
        }
    }
    
    /**
     post filtering process
     - Parameter selectedRange: NSRange.
     */
    func postFilteringProcess(in selectedRange: NSRange, completion:(() -> ())? = nil) {
        self.pickerView.tableView.reloadData()
        self.setPickerViewFrame(completion: {
                completion?()
        })
    }
}

/// JNMention Text View Delegate
public protocol JNMentionTextViewDelegate: UITextViewDelegate {
    
    /**
     Get Mention Item For
     - Parameter symbol: replacement string.
     - Parameter id: JNMentionEntityPickable ID.
     - Returns: JNMentionEntityPickable objects for the search criteria.
     */
    func getMentionItemFor(symbol: String, id: String) -> JNMentionPickable?
    
    /**
     Retrieve Data For
     - Parameter symbol: replacement string.
     - Parameter searchString: search string.
     - Returns: list of JNMentionEntityPickable objects for the search criteria.
     */
    func retrieveDataFor(_ symbol: String, using searchString: String) -> [JNMentionPickable]
    
    /**
     Cell For
     - Parameter item: JNMentionEntityPickable Item.
     - Parameter tableView: The data list UITableView.
     - Returns: UITableViewCell.
     */
    func cell(for item: JNMentionPickable, tableView: UITableView) -> UITableViewCell
    
    /**
     Height for cell
     - Parameter item: JNMentionEntityPickable item.
     - Parameter tableView: The data list UITableView.
     - Returns: cell height.
     */
    func heightForCell(for item: JNMentionPickable, tableView: UITableView) -> CGFloat
}


/// JNMentionTextViewDelegate
public extension JNMentionTextViewDelegate {

    /**
     Cell For
     - Parameter item: JNMentionEntityPickable Item.
     - Parameter tableView: The data list UITableView.
     - Returns: UITableViewCell.
     */
    func cell(for item: JNMentionPickable, tableView: UITableView) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = item.getPickableTitle()
        return cell
    }
    
    /**
     Height for cell
     - Parameter item: JNMentionEntityPickable item.
     - Parameter tableView: The data list UITableView.
     - Returns: cell height.
     */
    func heightForCell(for item: JNMentionPickable, tableView: UITableView) -> CGFloat {
        return ComponentValues.defaultCellHeight
    }
}