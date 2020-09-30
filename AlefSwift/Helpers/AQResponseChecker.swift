//
//  AQResponse.swift
//  AlefSwift
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

typealias successBlockType = ([String : Any]) -> ()
typealias skipBlockType = () -> ()
typealias retryBlockType = () -> ()

class AQResponseChecker {
	
	static func checkResponse(result: [String : Any]?, vc: BaseVC, canSkip: Bool, onSuccess: successBlockType, onRetry: retryBlockType?) {
		checkResponse(result: result, vc: vc, canSkip: canSkip, onSuccess: onSuccess, onRetry: onRetry, onSkip: nil)
	}
	
	static func checkResponse(result: [String : Any]?, vc: BaseVC, canSkip: Bool, onSuccess: successBlockType, onRetry: retryBlockType?, onSkip: skipBlockType?) {
		vc.hideLoadingIndicator()
		let alert = vc.alertViewInit()
		guard let status = result?[AQ.fields.status] else {
			vc.view.endEditing(true)
			let doneButtonTitle = (onRetry != nil) ? NSLocalizedString("Ещё попытка", comment: "") : NSLocalizedString("ОК", comment: "")
			if onRetry != nil {
				alert.addButton(doneButtonTitle, backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil) {
					onRetry!()
				}
				if canSkip {
					alert.addButton(NSLocalizedString("Отмена", comment: ""), backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil, action: { (onSkip ?? {})() })
				}
			}
			alert.showCustom(NSLocalizedString("Проблемы с сервером", comment: ""), subTitle: NSLocalizedString("Мы устраним неполадки в ближайшее время", comment: ""), color: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1), icon: UIImage(named: "info_blue_icon_modal")!)
			return
		}
		if status as! Int != 0 && status as! Int != 403 {
			var _onRetry = onRetry
			if let recoverable  = result?["is_recoverable"] as? Int{
				if recoverable == 0 {
					_onRetry = nil
				}
			} else {
				_onRetry = nil
			}
			
			
			vc.view.endEditing(true)
			let doneButtonTitle = (_onRetry != nil) ? NSLocalizedString("Ещё попытка", comment: "") : NSLocalizedString("ОК", comment: "")
			if _onRetry != nil {
				alert.addButton(doneButtonTitle, backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil) {
					_onRetry!()
				}
				if canSkip {
					alert.addButton(NSLocalizedString("Отмена", comment: ""), backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil, action: { (onSkip ?? {})() })
				}
			} else {
				alert.addButton(doneButtonTitle, backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil) {
					(onSkip ?? {})()
				}
			}
			if let message = result?["message"] as? String {
				alert.showCustom(NSLocalizedString("Возникла проблема", comment: ""), subTitle: message, color: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1), icon: UIImage(named: "info_blue_icon_modal")!)
			} else {
				alert.showCustom(NSLocalizedString("Возникла проблема", comment: ""), subTitle: NSLocalizedString("Что-то пошло не так", comment: ""), color: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1), icon: UIImage(named: "info_blue_icon_modal")!)
			}
			return
		}
		onSuccess(result!)
	}
	
	static func showErrorInVC(vc: BaseVC, canSkip: Bool, onRetry: retryBlockType?) {
		showErrorInVC(vc: vc, canSkip: canSkip, onRetry: onRetry, onSkip: nil)
	}
	
	
	static func showErrorInVC(vc: BaseVC, canSkip: Bool, onRetry: retryBlockType?, onSkip: skipBlockType?) {
		vc.hideLoadingIndicator()
		let alert = vc.alertViewInit()
		vc.view.endEditing(true)
		let doneButtonTitle = (onRetry != nil) ? NSLocalizedString("Ещё попытка", comment: "") : NSLocalizedString("ОК", comment: "")
		if onRetry != nil {
			alert.addButton(doneButtonTitle, backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil) {
				onRetry!()
			}
			if canSkip {
				alert.addButton(NSLocalizedString("Отмена", comment: ""), backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil, action: { (onSkip ?? {})() })
			}
		} else {
			alert.addButton(doneButtonTitle, backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil) {
				(onSkip ?? {})()
			}
		}
		
		alert.showCustom("Не выходит связаться с сервером", subTitle: "Проверьте, что у вас работает интернет", color: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1), icon: UIImage(named: "info_blue_icon_modal")!)
	}
}

extension UIViewController {
	
	func alertViewInit() -> SCLAlertViewWideButton {
		let appearance = SCLAlertViewWideButton.SCLAppearance(
			kDefaultShadowOpacity: 0.5,
			kCircleBackgroundTopPosition: 50,
			kCircleHeight: 50,
			kCircleIconHeight: 50,
			kTitleTop: 80,
			kWindowWidth: 300,
			kWindowHeight: 300,
			kButtonHeight: 70.0,
			kTitleFont: UIFont(name: "Roboto-Medium", size: 18)!,
			kButtonFont: UIFont(name: "Roboto", size: 18)!,
			showCloseButton: false,
			contentViewCornerRadius: 25.0,
			buttonCornerRadius: 18.0,
			circleBackgroundColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			contentViewColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			titleColor: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		)
		return SCLAlertViewWideButton(appearance: appearance)
	}
}
