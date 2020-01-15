//
//  MaskedTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 9/28/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

open class MaskedTextField: UITextField {

    public let lettersAndDigitsReplacementChar: String = "*"
    public let anyLetterReplecementChar: String = "@"
    public let lowerCaseLetterReplecementChar: String = "a"
    public let upperCaseLetterReplecementChar: String = "A"
    public let digitsReplecementChar: String = "#"
    
    /**
     Var that holds the format pattern that you wish to apply
     to some text
     
     If the pattern is set to "" no mask would be applied and
     the textfield would behave like a normal one
     */
    var formatPattern: String = ""
    
    /**
     Var that holds the prefix to be added to the textfield
     
     If the prefix is set to "" no string will be added to the beggining
     of the text
     */
    var prefix: String = ""
    
    /**
     Var that have the maximum length, based on the mask set
     */
    open var maxLength: Int {
        get {
            return formatPattern.count + prefix.count
        }
        set { }
    }
    
    /**
     Overriding the var text from UITextField so if any text
     is applied programmatically by calling formatText
     */
    override open var text: String? {
        set {
            super.text = newValue
            self.formatText()
        }
        get {
            return nil
        }
    }
    
    /// setting text just for internal using
    internal var secureText: String? {
        return super.text
    }
    
    // MARK: - Text Padding
    var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    // MARK: - Constructor
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    deinit {
        self.deRegisterForNotifications()
    }
    
    // MARK: - Private Methods
    fileprivate func setup() {
        self.registerForNotifications()
    }
    
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(textDidChange),
                                             name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"),
                                             object: self)
    }
    
    fileprivate func deRegisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func textDidChange() {
        self.undoManager?.removeAllActions()
        self.formatText()
    }
    
    fileprivate func getOnlyDigitsString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.vgsAsciiDecimalDigits.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getOnlyLettersString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.letters.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getUppercaseLettersString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.uppercaseLetters.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getLowercaseLettersString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.lowercaseLetters.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getFilteredString(_ string: String) -> String {
        let charactersArray = string.components(separatedBy: CharacterSet.alphanumerics.inverted)
        return charactersArray.joined(separator: "")
    }
    
    fileprivate func getStringWithoutPrefix(_ string: String) -> String {
        if string.range(of: self.prefix) != nil {
            if string.count > self.prefix.count {
                let prefixIndex = string.index(string.endIndex, offsetBy: (string.count - self.prefix.count) * -1)
                return String(string[prefixIndex...])
            } else if string.count == self.prefix.count {
                return ""
            }
            
        }
        return string
    }
    
    // MARK: - Self Public Methods
    /**
     Func that formats the text based on formatPattern
     
     Override this function if you want to customize the behaviour of 
     the class
     */
    open func formatText() {
        var currentTextForFormatting = ""
        
        if let text = super.text {
            if text.count > 0 {
                currentTextForFormatting = self.getStringWithoutPrefix(text)
            }
        }
        
        if self.maxLength > 0 {
            var formatterIndex = self.formatPattern.startIndex, currentTextForFormattingIndex = currentTextForFormatting.startIndex
            var finalText = ""
            
            currentTextForFormatting = self.getFilteredString(currentTextForFormatting)
            
            if currentTextForFormatting.count > 0 {
                while true {
                    let formatPatternRange = formatterIndex ..< formatPattern.index(after: formatterIndex)
                    let currentFormatCharacter = String(self.formatPattern[formatPatternRange])
                    
                    let currentTextForFormattingPatterRange = currentTextForFormattingIndex ..< currentTextForFormatting.index(after: currentTextForFormattingIndex)
                    let currentTextForFormattingCharacter = String(currentTextForFormatting[currentTextForFormattingPatterRange])
                    
                    switch currentFormatCharacter {
                    case self.lettersAndDigitsReplacementChar:
                        finalText += currentTextForFormattingCharacter
                        currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                        formatterIndex = formatPattern.index(after: formatterIndex)
                    case self.anyLetterReplecementChar:
                        let filteredChar = self.getOnlyLettersString(currentTextForFormattingCharacter)
                        if !filteredChar.isEmpty {
                            finalText += filteredChar
                            formatterIndex = formatPattern.index(after: formatterIndex)
                        }
                        currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                    case self.lowerCaseLetterReplecementChar:
                        let filteredChar = self.getLowercaseLettersString(currentTextForFormattingCharacter)
                        if !filteredChar.isEmpty {
                            finalText += filteredChar
                            formatterIndex = formatPattern.index(after: formatterIndex)
                        }
                        currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                    case self.upperCaseLetterReplecementChar:
                        let filteredChar = self.getUppercaseLettersString(currentTextForFormattingCharacter)
                        if !filteredChar.isEmpty {
                            finalText += filteredChar
                            formatterIndex = formatPattern.index(after: formatterIndex)
                        }
                        currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                    case self.digitsReplecementChar:
                        let filteredChar = self.getOnlyDigitsString(currentTextForFormattingCharacter)
                        if !filteredChar.isEmpty {
                            finalText += filteredChar
                            formatterIndex = formatPattern.index(after: formatterIndex)
                        }
                        currentTextForFormattingIndex = currentTextForFormatting.index(after: currentTextForFormattingIndex)
                    default:
                        finalText += currentFormatCharacter
                        formatterIndex = formatPattern.index(after: formatterIndex)
                    }
                    
                    if formatterIndex >= self.formatPattern.endIndex ||
                        currentTextForFormattingIndex >= currentTextForFormatting.endIndex {
                        break
                    }
                }
            }
            
            if finalText.count > 0 {
                super.text = "\(self.prefix)\(finalText)"
            } else {
                super.text = finalText
            }
            
            if let text = self.text {
                if text.count > self.maxLength {
                    super.text = String(text[text.index(text.startIndex, offsetBy: self.maxLength)])
                }
            }
        }
    }
}
