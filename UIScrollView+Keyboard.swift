/*
The MIT License (MIT)

Copyright (c) 2016 azouts

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//
//  UIScrollView+Keyboard.swift
//  Zoutsos
//
//  Created by Aristidis Zoutsos on 1/10/16.
//  Copyright © 2016 Aristidis Zoutsos. All rights reserved.
//

import Foundation

extension UIScrollView {
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func adjustAutomaticallyForKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var heightOfTabBar = CGFloat(0.0)
        var heightOfToobar = CGFloat(0.0)
        
        if let vc = appDelegate.window?.rootViewController as? UITabBarController {
            heightOfTabBar = vc.tabBar.frame.height
        }
        
        if let vc = appDelegate.window?.rootViewController as? UINavigationController {
            heightOfToobar = vc.toolbar.frame.height
        }
        
        if let userInfo = notification.userInfo {
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
            UIView.animateWithDuration(duration) { () -> Void in
                let kbsize: CGSize! = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size
                let contentInsets = UIEdgeInsets(top: self.contentInset.top, left: 0, bottom: (kbsize?.height)! - heightOfTabBar - heightOfToobar, right: 0)
                self.contentInset = contentInsets
                self.scrollIndicatorInsets = contentInsets
                self.flashScrollIndicators()
            }
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, let kbsize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
            self.scrollFirstResponderToVisible(kbsize.height)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
            UIView.animateWithDuration(duration, animations: { () -> Void in
                let contentInsets = UIEdgeInsets(top: self.contentInset.top, left: 0, bottom: 0, right: 0)
                self.contentInset = contentInsets
                self.scrollIndicatorInsets = contentInsets
                self.flashScrollIndicators()
            })
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
    }
    
    private func scrollFirstResponderToVisible(keybHeight: CGFloat, view: UIView? = nil) {
        let view = view ?? self
        for v in view.subviews {
            if v.isFirstResponder() {
                var r = self.frame
                r.size.height -= keybHeight
                
                if !CGRectContainsPoint(r, v.frame.origin) {
                    //scroll if neccessary
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    var heightOfTabBar = CGFloat(0.0)
                    var heightOfToobar = CGFloat(0.0)
                    
                    if let vc = appDelegate.window?.rootViewController as? UITabBarController {
                        heightOfTabBar = vc.tabBar.frame.height
                    }
                    
                    if let vc = appDelegate.window?.rootViewController as? UINavigationController {
                        heightOfToobar = vc.toolbar.frame.height
                    }
                    
                    self.setContentOffset(CGPointMake(0, abs(frame.height - keybHeight - v.frame.origin.y - heightOfTabBar - heightOfToobar)), animated: true)
                }
                return
            } else {
                scrollFirstResponderToVisible(keybHeight, view: v)
            }
        }
    }
}
