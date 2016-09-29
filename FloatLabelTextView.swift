//
//  FloatLabelTextView.swift
//  FloatLabelFields

//  Created by Phani on 26/09/16.
//  Copyright © 2016 Ashok. All rights reserved.

//  Original Concept by Matt D. Smith
//  http://dribbble.com/shots/1254439--GIF-Mobile-Form-Interaction?list=users
//
//  Objective-C version by Jared Verdi
//  https://github.com/jverdi/JVFloatLabeledTextField
//
//
//  Updated for Swift 3.0 by Phani on  26/09/16.


import UIKit

@IBDesignable class FloatLabelTextView: UITextView {
	let animationDuration = 0.3
	let placeholderTextColor = UIColor.blue
	private var isIB = false
    var title = UILabel()
	private var hintLabel = UILabel()
	private var initialTopInset:CGFloat = 0
    var isTitleShown = false
	
	// MARK:- Properties
	override var accessibilityLabel:String? {
		get {
			if text.isEmpty {
				return title.text!
			} else {
				return text
			}
		}
		set {
		}
	}
	
	var titleFont:UIFont = UIFont.systemFont(ofSize: 12.0) {
		didSet {
			title.font = titleFont
		}
	}
	
	@IBInspectable var hint:String = "" {
		didSet {
			title.text = hint
			title.sizeToFit()
			var r = title.frame
			r.size.width = frame.size.width
			title.frame = r
			hintLabel.text = hint
			hintLabel.sizeToFit()
		}
	}
	
	@IBInspectable var hintYPadding:CGFloat = 0.0 {
		didSet {
			adjustTopTextInset()
		}
	}
	
	@IBInspectable var titleYPadding:CGFloat = 0.0 {
		didSet {
			var r = title.frame
			r.origin.y = titleYPadding
			title.frame = r
		}
	}
	
	@IBInspectable var titleTextColour:UIColor = UIColor.gray{
		didSet {
			if !isFirstResponder {
				title.textColor = titleTextColour
			}
		}
	}
	
	@IBInspectable var titleActiveTextColour:UIColor = UIColor.cyan {
		didSet {
			if isFirstResponder {
				title.textColor = titleActiveTextColour
			}
		}
	}
    
//    @IBInspectable var lineViewBgColor:UIColor = UIColor.grayColor() {
//        didSet {
//            if !isFirstResponder() {
//                lineView.backgroundColor = lineViewBgColor
//            }
//        }
//    }
	
	// MARK:- Init
	required init?(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)!
		setup()
	}
	
	override init(frame:CGRect, textContainer:NSTextContainer?) {
		super.init(frame:frame, textContainer:textContainer)
		setup()
	}
	
	deinit {
		if !isIB {
			let nc = NotificationCenter.default
			nc.removeObserver(self, name:NSNotification.Name.UITextViewTextDidChange, object:self)
			nc.removeObserver(self, name:NSNotification.Name.UITextViewTextDidBeginEditing, object:self)
			nc.removeObserver(self, name:NSNotification.Name.UITextViewTextDidEndEditing, object:self)
		}
	}
	
	// MARK:- Overrides
	override func prepareForInterfaceBuilder() {
		isIB = true
		setup()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		adjustTopTextInset()
		hintLabel.alpha = text.isEmpty ? 1.0 : 0.0
		let r = textRect()
		hintLabel.frame = CGRect(x:r.origin.x, y:r.origin.y, width:hintLabel.frame.size.width, height:hintLabel.frame.size.height)
		setTitlePositionForTextAlignment()
		let isResp = isFirstResponder
		if isResp && !text.isEmpty {
			title.textColor = titleActiveTextColour
//            lineView.backgroundColor = lineViewBgColor
		} else {
			title.textColor = titleActiveTextColour
//            lineView.backgroundColor = titleActiveTextColour
		}
		// Should we show or hide the title label?
        if text.isEmpty {
            // Hide
            if isTitleShown {
                hideTitle(animated: isResp)
            }
        } else {
            // Show
            if isTitleShown {
                showTitle(animated: false)
            } else {
                showTitle(animated: isResp)
            }
        }
	}
	
	// MARK:- Private Methods
	private func setup() {
		initialTopInset = textContainerInset.top
		textContainer.lineFragmentPadding = 0.0
		titleActiveTextColour = tintColor
		// Placeholder label
		hintLabel.font = font
		hintLabel.text = hint
		hintLabel.numberOfLines = 1
		hintLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		hintLabel.backgroundColor = UIColor.clear
		hintLabel.textColor = placeholderTextColor
		insertSubview(hintLabel, at:0)
		// Set up title label
		title.alpha = 0.0
		title.font = titleFont
		title.textColor = titleTextColour
		if !hint.isEmpty {
			title.text = hint
			title.sizeToFit()
		}
		self.addSubview(title)
//        lineView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 1)
//        lineView.backgroundColor = titleActiveTextColour
//        self.addSubview(lineView)
		// Observers
		if !isIB {
			let nc = NotificationCenter.default
			nc.addObserver(self, selector:#selector(UIView.layoutSubviews), name:NSNotification.Name.UITextViewTextDidChange, object:self)
			nc.addObserver(self, selector:#selector(UIView.layoutSubviews), name:NSNotification.Name.UITextViewTextDidBeginEditing, object:self)
			nc.addObserver(self, selector:#selector(UIView.layoutSubviews), name:NSNotification.Name.UITextViewTextDidEndEditing, object:self)
		}
	}

	private func adjustTopTextInset() {
		var inset = textContainerInset
		inset.top = initialTopInset + title.font.lineHeight + hintYPadding
		textContainerInset = inset
	}
	
	private func textRect()->CGRect {
		var r = UIEdgeInsetsInsetRect(bounds, contentInset)
		r.origin.x += textContainer.lineFragmentPadding
		r.origin.y += textContainerInset.top
		return r.integral
	}
	
	private func setTitlePositionForTextAlignment() {
		var titleLabelX = textRect().origin.x
		var placeholderX = titleLabelX
		if textAlignment == NSTextAlignment.center {
			titleLabelX = (frame.size.width - title.frame.size.width) * 0.5
			placeholderX = (frame.size.width - hintLabel.frame.size.width) * 0.5
		} else if textAlignment == NSTextAlignment.right {
			titleLabelX = frame.size.width - title.frame.size.width
			placeholderX = frame.size.width - hintLabel.frame.size.width
		}
//        lineView.frame = CGRectMake(0, 40, self.frame.size.width, 1)
		var r = title.frame
		r.origin.x = titleLabelX
		title.frame = r
		r = hintLabel.frame
		r.origin.x = placeholderX
		hintLabel.frame = r
	}
	
    private func showTitle(animated:Bool) {
        isTitleShown = true
        
        func changeTheFrame() {
            self.title.alpha = 1.0
            var r = self.title.frame
            r.origin.y = self.titleYPadding + self.contentOffset.y
            self.title.frame = r
        }
        
        if animated {
            let dur = animated ? animationDuration : 0
            UIView.animate(withDuration: dur, delay:0, options: [.beginFromCurrentState, .curveEaseOut], animations:{
                // Animation
                changeTheFrame()
                }, completion:nil)
        } else {
            changeTheFrame()
        }
    }
	
	private func hideTitle(animated:Bool) {
        isTitleShown = false
		let dur = animated ? animationDuration : 0
		UIView.animate(withDuration: dur, delay:0, options: [.beginFromCurrentState, .curveEaseIn], animations:{
			// Animation
			self.title.alpha = 0.0
			var r = self.title.frame
			r.origin.y = self.title.font.lineHeight + self.hintYPadding
			self.title.frame = r
			}, completion:nil)
	}
}
