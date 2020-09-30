//
//  UIView+LayerEffects.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер on 12/07/2020.
//  Copyright © 2020 Alef. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
	
	@IBInspectable
	public var cornerRadius: CGFloat
	{
		set (radius) {
			self.layer.cornerRadius = radius
			self.layer.masksToBounds = radius > 0
		}
		
		get {
			return self.layer.cornerRadius
		}
	}
	
	@IBInspectable
	public var borderWidth: CGFloat
	{
		set (borderWidth) {
			self.layer.borderWidth = borderWidth
		}
		
		get {
			return self.layer.borderWidth
		}
	}
	
	@IBInspectable
	public var borderColor:UIColor?
	{
		set (color) {
			self.layer.borderColor = color?.cgColor
		}
		
		get {
			if let color = self.layer.borderColor
			{
				return UIColor(cgColor: color)
			} else {
				return nil
			}
		}
	}
	
	
	@IBInspectable
	public var shadowRadius: CGFloat
	{
		set (shadowRadius) {
			self.layer.shadowRadius = shadowRadius
		}
		
		get {
			return self.layer.shadowRadius
		}
	}
	
	@IBInspectable
	public var shadowColor: UIColor?
	{
		set (color) {
			self.layer.shadowColor = color?.cgColor
		}
		
		get {
			if let color = self.layer.shadowColor
			{
				return UIColor(cgColor: color)
			} else {
				return nil
			}
		}
	}
	
	@IBInspectable
	public var shadowOffset: CGSize
	{
		set (shadowOffset) {
			self.layer.shadowOffset = shadowOffset
		}
		
		get {
			return self.layer.shadowOffset
		}
	}
	
	@IBInspectable
	public var shadowOpacity: CGFloat
	{
		set (shadowOpacity) {
			self.layer.shadowOpacity = Float(shadowOpacity)
		}
		
		get {
			return CGFloat(self.layer.shadowOpacity)
		}
	}
}
