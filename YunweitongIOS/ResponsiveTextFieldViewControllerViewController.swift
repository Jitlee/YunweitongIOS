//
//  ResponsiveTextFieldViewControllerViewController.swift
//  LonzaReportApp
//
//  Created by 品佳 万 on 15/6/14.
//  Copyright (c) 2015年 品佳 万. All rights reserved.
//

import UIKit

class ResponsiveTextFieldViewController : BaseUIViewController
{
    
    private let kPreferredTextFieldToKeyboardOffset: CGFloat = 20.0
    private var keyboardHeight: CGFloat?
    private var keyboardIsShowing: Bool = false
    private weak var activeTextField: UITextField?
    private weak var scrollView: UIScrollView?
    private weak var bottomView: UIView?
    private var tabMaps = [UIControl]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        for subview in self.view.subviews
        {
            if let scrollView = subview as? UIScrollView {
                self.scrollView = scrollView
                initEvents(scrollView)
            }
        }
    }
    
    private func initEvents(view: UIView) {
        for subview in view.subviews
        {
            if (subview.isKindOfClass(UITextField))
            {
                var textField = subview as! UITextField
                textField.addTarget(self, action: "textFieldDidReturn:", forControlEvents: UIControlEvents.EditingDidEndOnExit)
                
                textField.addTarget(self, action: "textFieldDidBeginEditing:", forControlEvents: UIControlEvents.EditingDidBegin)
            }
            
            if let ctrl = subview as? UIControl {
                tabMaps.append(ctrl)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if self.keyboardIsShowing {
            return
        }
        
        if let info = notification.userInfo {
            var theApp: UIApplication = UIApplication.sharedApplication()
            var windowView: UIView? = theApp.delegate!.window!
            
            let rectValue = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            self.keyboardHeight = rectValue.height + CGFloat(kTallCapsSelector)
            let offset = self.activeTextField!.frame.origin.y
                + self.activeTextField!.frame.size.height
                - (self.scrollView!.frame.size.height - self.keyboardHeight!)
            
            if(offset > 0) {
                self.scrollView?.contentOffset.y = offset
            }
        }
        
        self.keyboardIsShowing = true
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.keyboardIsShowing = false
        
        self.returnViewToInitialFrame()
    }
    
    func returnViewToInitialFrame()
    {
        var initialViewRect: CGRect = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        
        if (!CGRectEqualToRect(initialViewRect, self.view.frame))
        {
            UIView.animateWithDuration(0.2, animations: {
                self.view.frame = initialViewRect
            });
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if (self.activeTextField != nil)
        {
            self.activeTextField?.resignFirstResponder()
            self.activeTextField = nil
        }
    }
    
    @IBAction func textFieldDidReturn(textField: UITextField!)
    {
        //textField.resignFirstResponder()
        self.activeTextField = nil
        if let index = find(tabMaps, textField) {
            let next: UIControl? = tabMaps[index + 1]
            if let button = next as? UIButton {
                button.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            } else {
                next!.becomeFirstResponder()
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        self.activeTextField = textField
    }
    
    override func viewDidLayoutSubviews() {
        let contentHeight = findContenxtHeight(scrollView!)
        scrollView!.contentSize = CGSizeMake(0, contentHeight)
    }
    
    private func findContenxtHeight(view: UIView) -> CGFloat {
        var maxY: CGFloat! = CGFloat.min
        
        if bottomView == nil {
            for subView in view.subviews {
                if let control = subView as? UIView {
                    if maxY < control.bounds.maxY {
                        maxY = control.bounds.maxY
                        bottomView = control
                    }
                }
            }
        } else {
            maxY = bottomView?.bounds.maxY
        }
        
        //return max(maxY, self.view.frame.size.height)
        
        var contentHeight = max(maxY, self.view.frame.size.height)
        if self.keyboardIsShowing {
            contentHeight += self.keyboardHeight!
        }
        
        return contentHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        tabMaps.removeAll(keepCapacity: false)
    }
}