//
//  ViewController.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер.
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import SideMenuSwift
import ActionSheetPicker_3_0

enum NewsVCMode {
	case group
	case homepage
	case myProfile
	case profile
	case search
}

class NewsVC: BaseVC {
	
	private var mode: NewsVCMode = .homepage
	private var groupId = 0
	private var userId = 0
    override var v: NewsView! { return self.view as? NewsView }
	var posts : [[String: Any?]] { state[AQ.fields.items] as? [[String: Any?]] ?? [] }
       
	func setScreenModeToGroup(_ _groupId: Int) {
		mode = .group
		groupId = _groupId
	}
	
	func setScreenModeToHomepage() {
		mode = .homepage
	}
	
	func setScreenModeToProfile(user _userId: Int) {
		userId = _userId
		if (userId == 0) {
			mode = .myProfile
		} else {
			mode = .profile
		}		
	}
	
	func setScreenModeToSearch(serverData: [String: Any?]) {
		mode = .search
		var data = serverData
		data["mode"] = mode
		self.v.prepareForEmbedding()
		
		// установка стейта приводит к отрисовке
		// вызывать отрисовку до добавления в структуру View плохо
		// поэтому делаем это с задержкой
		DispatchQueue.main.asyncAfter(deadline: .now()) {
			self.state = data
		}
	}
	
	@objc private func populateFromServer() {
		populateFromServer(page: 0)
	}
	
	@objc private func populateFromServer(page: Int) {
		let pageSize = 20
		var uid = 0
		var gid = 0
				
		if (mode == .group) {
			gid = groupId
		} else if (mode == .profile || mode == .myProfile) {
			uid = userId
		}
		
		showLoadingIndicator()
		
        AQ.getFeed(user_id: uid, group_id: gid, offset: page * pageSize, limit: pageSize, search_query: "", created_ts_from: 0, created_ts_to: 0, forced_post_id: 1, failure: { (error) in
			self.hideLoadingIndicator()
			AQResponseChecker.showErrorInVC(vc: self, canSkip: false, onRetry: {
				self.perform(#selector(self.populateFromServer as () -> Void), with: nil, afterDelay: 1)
			}, onSkip: nil)
		}) { (resp) in
			self.hideLoadingIndicator()
			AQResponseChecker.checkResponse(result: resp, vc: self, canSkip: false, onSuccess: { (resp) in
				var newState = self.state
				if newState[AQ.fields.items] != nil && newState[AQ.fields.items] is [[String: Any?]]{
					var items = newState[AQ.fields.items] as! [[String: Any?]]
					if let newItems = newState[AQ.fields.items] as? [[String: Any?]] {
						items.append(contentsOf: newItems)
					}
					newState[AQ.fields.items] = items
				} else {
					newState[AQ.fields.items] = resp[AQ.fields.items]
				}
				newState["mode"] = self.mode
				newState["user_id"] = uid
				newState["group_id"] = gid
				
				self.state = newState
			}, onRetry: {
				self.perform(#selector(self.populateFromServer as () -> Void), with: nil, afterDelay: 1)
			}, onSkip: nil)
		}
		
	}
		
	
	override func viewDidLoad() {
		super.viewDidLoad();
//		
//		self.state = ["items":[["id":1], ["id":2]]] //!@# delete me
//		addPostsToState(newPosts: [["id":2], ["id":3]]) //!@# delete me
//		print(self.state) //!@# delete me
		
		v.onControllerEmbeded = { [weak self] (vc) in
			if let self = self {
				vc.parentNewsVC = self
				self.addChild(vc)
				vc.didMove(toParent: self)
			}
		}
		
		v.onNavBarRendered = {[weak self] (leftBtn) in
			if let self = self {
				self.sideMenuLeftButtonContainer = leftBtn
				self.setupSideMenuLeftButton()
			}
		}
		
		v.onUserClicked = { [weak self] (userId) in
			if let vc = UIStoryboard(name: "News", bundle: nil).instantiateViewController(withIdentifier: "News") as? NewsVC {
				if let self = self {
					vc.setScreenModeToProfile(user: userId)
					self.navigationController?.pushViewController(vc, animated: true)
				}
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		populateFromServer()
		
	}
	

	@IBAction func userNameBtnPressed(_ sender: UIButton) {
		if let vc = UIStoryboard(name: "News", bundle: nil).instantiateViewController(withIdentifier: "News") as? NewsVC {
			vc.setScreenModeToProfile(user: sender.tag)
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func searchBtnPressed(_ sender: UIButton) {
		if let searchVC = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "Search") as? SearchVC {
			navigationController?.pushViewController(searchVC, animated: true)
		}
	}
	
	@IBAction func groupBtnPressed(_ sender: UIButton) {
		if let profileVC = UIStoryboard(name: "News", bundle: nil).instantiateViewController(withIdentifier: "News") as? NewsVC {
			profileVC.setScreenModeToGroup(sender.tag)
			navigationController?.pushViewController(profileVC, animated: true)
		}
	}
	
	@IBAction func attachmentBtnPressed(_ sender: UIButton) {
		if let attachments = attachmentsArrayByAttachmentUniqueId(id: sender.accessibilityLabel) {
			if let vc = UIStoryboard(name: "Attachments", bundle: nil).instantiateInitialViewController() as? AttachmentsVC {
				self.navigationController?.pushViewController(vc, animated: true)
				vc.setAttachments(attachments)
			}
		}
	}
	
	@IBAction func moreBtnPressed(_ sender: UIButton) {
		let postId = sender.tag
		let post = posts.first { $0[AQ.fields.id] as? Int ?? 0 == postId }
		let textExpanded = post?["textExpanded"] as? Bool ?? false
		
		change(property: "textExpanded", to: !textExpanded, inPost: postId)
	}
	
	@IBAction func deleteBtnPressed(_ sender: UIButton) {
		let appearance = SCLAlertViewWideButton.SCLAppearance(
			kDefaultShadowOpacity: 0.5,
			kCircleBackgroundTopPosition: 50,
			kCircleHeight: 50,
			kCircleIconHeight: 50,
			kTitleTop: 80,
			kWindowWidth: 300,
			kWindowHeight: 300,
			kButtonHeight: 50.0,
			kTitleFont: UIFont(name: "Roboto-Medium", size: 18)!,
			kButtonFont: UIFont(name: "Roboto", size: 18)!,
			showCloseButton: false,
			contentViewCornerRadius: 25.0,
			buttonCornerRadius: 18.0,
			circleBackgroundColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			contentViewColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			titleColor: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		)
		let alert = SCLAlertViewWideButton(appearance: appearance)
		
		
		alert.addButton(NSLocalizedString("Отмена", comment: ""), backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil) {
			
		}
		
		alert.addButton(NSLocalizedString("Удалить", comment: ""), backgroundColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), textColor : #colorLiteral(red: 1, green: 0.00800000038, blue: 0.00800000038, alpha: 1), showTimeout: nil) {
			self.showLoadingIndicator()
			AQ.deletePost(post_id: sender.tag, failure: { (error) in
				AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
					self.deleteBtnPressed(sender)
				}
			}) { (result) in
				AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: { (result) in
					self.state[AQ.fields.items] = self.posts.filter { $0[AQ.fields.id] as? Int ?? 0 != sender.tag }
				}) {
					self.deleteBtnPressed(sender)
				}
			}
		}
		
		alert.showCustom(NSLocalizedString("Вы уверены?", comment: ""), subTitle: NSLocalizedString("Удаленный пост нельзя будет восстановить", comment: ""), color: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1), icon: UIImage(named: "info_blue_icon_modal")!)
	}
	
	@IBAction func editBtnPressed(_ sender: UIButton) {
		if let vc = UIStoryboard(name: "CreateEditPost", bundle: nil).instantiateInitialViewController() as? CreateEditPostVC {
			if let post = posts.first(where: { $0[AQ.fields.id] as? Int ?? 0 == sender.tag }) {
				self.navigationController?.pushViewController(vc, animated: true)
				vc.state = post
			}
		}
	}
		
	
	func change(property: String, to value: Any, inPost id: Int) {
		var newPosts:[[String: Any?]] = []
		self.posts.forEach({ (source) in
			if let source_id = source[AQ.fields.id] as? Int {
				if source_id == id {
					var mutablePost = source;
					mutablePost[property] = value
					newPosts.append(mutablePost);
				} else {
					newPosts.append(source);
				}
			}
		})
		var newState:[String: Any?] = state
		newState[AQ.fields.items] = newPosts
		self.state = newState
	}
	
	@IBAction func createNewPost(_ sender: Any) {
		if let vc = UIStoryboard(name: "CreateEditPost", bundle: nil).instantiateInitialViewController() as? CreateEditPostVC {
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func repostBtnPressed(_ sender: UIButton) {
		let appearance = SCLAlertViewWideButton.SCLAppearance(
			kDefaultShadowOpacity: 0.5,
			kCircleBackgroundTopPosition: 50,
			kCircleHeight: 50,
			kCircleIconHeight: 50,
			kTitleTop: 80,
			kWindowWidth: 300,
			kWindowHeight: 300,
			kButtonHeight: 50.0,
			kTitleFont: UIFont(name: "Roboto-Medium", size: 18)!,
			kButtonFont: UIFont(name: "Roboto", size: 18)!,
			showCloseButton: false,
			contentViewCornerRadius: 25.0,
			buttonCornerRadius: 18.0,
			circleBackgroundColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			contentViewColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			titleColor: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		)
		let alert = SCLAlertViewWideButton(appearance: appearance)
		
		
		
		
		alert.addButton(NSLocalizedString("Репост", comment: ""), backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil) {
			self.showLoadingIndicator()
			AQ.repost(post_id: sender.tag, failure: { (error) in
				AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
					self.repostBtnPressed(sender)
				}
			}) { (result) in
				AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: { (result) in
					
				}) {
					self.repostBtnPressed(sender)
				}
			}
		}
		
		alert.addButton(NSLocalizedString("Отмена", comment: ""), backgroundColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), textColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), showTimeout: nil) {
			
		}
		
		alert.showCustom(NSLocalizedString("Сделать репост?", comment: ""), subTitle: NSLocalizedString("Этот пост попадет в вашу ленту", comment: ""), color: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1), icon: UIImage(named: "info_blue_icon_modal")!)
	}
	
	@IBAction func documentBtnPressed(_ sender: UIButton) {
		if let urlString = sender.accessibilityIdentifier {
			let url = URL(string: urlString)
			let fileName = String((url!.lastPathComponent)) as NSString

			let documentsUrl:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
			let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)_" + Date().timeIntervalSince1970.description)
			
			let fileURL = URL(string: urlString)
			let sessionConfig = URLSessionConfiguration.default
			let session = URLSession(configuration: sessionConfig)
			let request = URLRequest(url:fileURL!)
			showLoadingIndicator()
			let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
				if let tempLocalUrl = tempLocalUrl, error == nil {
					
					if let statusCode = (response as? HTTPURLResponse)?.statusCode {
						if statusCode == 200 {
							do {
								try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
								do {
									let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
									for indexx in 0..<contents.count {
										if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
											let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
											DispatchQueue.main.async {
												self.hideLoadingIndicator()
												self.present(activityViewController, animated: true, completion: nil)
											}
										}
									}
								}
								catch {
									DispatchQueue.main.async {
										self.hideLoadingIndicator()
										self.alert(title: "Ошибка", text: "Не удалось сохранить файл")
									}
								}
							} catch {
								DispatchQueue.main.async {
									self.hideLoadingIndicator()
									self.alert(title: "Ошибка", text: "Не удалось сохранить файл")
								}
							}
						} else {
							self.alert(title: "Ошибка", text: "Не удалось сохранить файл")
						}
					}
					
				} else {
					DispatchQueue.main.async {
						self.hideLoadingIndicator()
						self.alert(title: "Ошибка", text: "Не удалось сохранить файл")
					}
				}
			}
			task.resume()
		}
	}
		
	@IBAction func linkBtnPressed(_ sender: UIButton) {
		if let urlString = sender.accessibilityIdentifier {
			if let url = URL(string: urlString) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
	}
	
	@IBAction func filterBtnPressed(_ sender: Any) {
		var filter = state["filter"] as? [String: Any?] ?? [:]
		let expanded = !(filter["isExpanded"] as? Bool ?? false)
		filter["isExpanded"] = expanded
		state["filter"] = filter
	}
	
	func getFilterGroupListAndCall(callback success: @escaping ([String: Any?])->()) {
		showLoadingIndicator()
		if mode == .homepage {
			AQ.getGroups(country_id: 0, only_my_groups: 0, failure: { (err) in
				self.hideLoadingIndicator()
				AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
					self.filterGroupsBtnPressed(self)
				}
			}) { (result) in
				self.hideLoadingIndicator()
				AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: success) {
					self.filterGroupsBtnPressed(self)
				}
			}
		}
	}
	
	@IBAction func filterGroupsBtnPressed(_ sender: Any) {
		getFilterGroupListAndCall {result in
			if let groups = result[AQ.fields.groups] as? [[String: Any?]] {
				let indexMap = groups.map { $0[AQ.fields.id] }
				let titles = ["Все группы"] + groups.compactMap { $0[AQ.fields.name] as? String}
				
				let picker = ActionSheetStringPicker(title: NSLocalizedString("Выберите группу", comment: ""), rows: titles, initialSelection: 0, doneBlock: { (picker, index, value) in
					var filter = self.state["filter"] as? [String: Any?] ?? [:]
					if let value = value as? String {
						filter["groupStr"] = value
						filter["groupId"] = indexMap[index]
					}
					self.state["filter"] = filter
				}, cancel: { (picker) in
					
				}, origin: sender)
				
				picker?.setDoneButton(UIBarButtonItem(title: NSLocalizedString("Готово", comment: ""), style: .plain, target: nil, action: nil))
				picker?.setCancelButton(UIBarButtonItem(title: NSLocalizedString("Отмена", comment: ""), style: .plain, target: nil, action: nil))
				picker?.show()
			}
		}
	}
	
	@IBAction func filterDateFromBtnPressed(_ sender: UIButton) {
		let picker = ActionSheetDatePicker(title: NSLocalizedString("Дата начала периода", comment: ""), datePickerMode: .date, selectedDate: Date(), doneBlock: { (picker, date, btn) in
			var filter = self.state["filter"] as? [String: Any?] ?? [:]
			if let date = date as? Date {
				let formatter = DateFormatter()
				formatter.timeStyle = .none
				formatter.dateStyle = .long
				formatter.locale = NSLocale.current
				filter["dateFromStr"] = formatter.string(from: date)
				filter["dateFrom"] = date
			}
		
			self.state["filter"] = filter
		}, cancel: { (picker) in
			
		}, origin: sender)
		
		picker?.setDoneButton(UIBarButtonItem(title: NSLocalizedString("Готово", comment: ""), style: .plain, target: nil, action: nil))
		picker?.setCancelButton(UIBarButtonItem(title: NSLocalizedString("Отмена", comment: ""), style: .plain, target: nil, action: nil))
		picker?.show()
	}
	
	@IBAction func filterDateToBtnPressed(_ sender: UIButton) {
		let picker = ActionSheetDatePicker(title: NSLocalizedString("Дата конца периода", comment: ""), datePickerMode: .date, selectedDate: Date(), doneBlock: { (picker, date, btn) in
			var filter = self.state["filter"] as? [String: Any?] ?? [:]
			if let date = date as? Date {
				let formatter = DateFormatter()
				formatter.timeStyle = .none
				formatter.dateStyle = .long
				formatter.locale = NSLocale.current
				filter["dateToStr"] = formatter.string(from: date)
				filter["dateToFrom"] = date
			}
			
			self.state["filter"] = filter
		}, cancel: { (picker) in
			
		}, origin: sender)
		
		picker?.setDoneButton(UIBarButtonItem(title: NSLocalizedString("Готово", comment: ""), style: .plain, target: nil, action: nil))
		picker?.setCancelButton(UIBarButtonItem(title: NSLocalizedString("Отмена", comment: ""), style: .plain, target: nil, action: nil))
		picker?.show()
	}
	
	@IBAction func clearFilterBtnPressed(_ sender: Any) {
		let filter = state["filter"] as? [String: Any?] ?? [:]
		let expanded = filter["isExpanded"] as? Bool ?? false
		self.state["filter"] = ["isExpanded": expanded]
	}
	
	@IBAction func applyFilterBtnPressed(_ sender: UIButton) {
	}
	
	@IBAction func editCommentBtnPressed(_ sender: UIButton) {
	}
	
	@IBAction func deleteCommentBtnPressed(_ sender: UIButton) {
		
		let appearance = SCLAlertViewWideButton.SCLAppearance(
			kDefaultShadowOpacity: 0.5,
			kCircleBackgroundTopPosition: 50,
			kCircleHeight: 50,
			kCircleIconHeight: 50,
			kTitleTop: 80,
			kWindowWidth: 300,
			kWindowHeight: 300,
			kButtonHeight: 50.0,
			kTitleFont: UIFont(name: "Roboto-Medium", size: 18)!,
			kButtonFont: UIFont(name: "Roboto", size: 18)!,
			showCloseButton: false,
			contentViewCornerRadius: 25.0,
			buttonCornerRadius: 18.0,
			circleBackgroundColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			contentViewColor: #colorLiteral(red: 0.8629999757, green: 0.8629999757, blue: 0.8629999757, alpha: 1),
			titleColor: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1)
		)
		let alert = SCLAlertViewWideButton(appearance: appearance)
		
		
		alert.addButton(NSLocalizedString("Отмена", comment: ""), backgroundColor: #colorLiteral(red: 0.3610000014, green: 0.7220000029, blue: 0.6980000138, alpha: 1), textColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), showTimeout: nil) {
			
		}
		
		alert.addButton(NSLocalizedString("Удалить", comment: ""), backgroundColor: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1), textColor : #colorLiteral(red: 1, green: 0.00800000038, blue: 0.00800000038, alpha: 1), showTimeout: nil) {
			self.showLoadingIndicator()
			AQ.deleteComment(comment_id: sender.tag, failure: { (error) in
				AQResponseChecker.showErrorInVC(vc: self, canSkip: true) {
					self.deleteCommentBtnPressed(sender)
				}
			}) { (result) in
				AQResponseChecker.checkResponse(result: result, vc: self, canSkip: true, onSuccess: { (result) in
					self.deleteCommentFromState(id: sender.tag)
				}) {
					self.deleteCommentBtnPressed(sender)
				}
			}
		}
		
		alert.showCustom(NSLocalizedString("Вы уверены?", comment: ""), subTitle: NSLocalizedString("Удаленный комментарий нельзя будет восстановить", comment: ""), color: #colorLiteral(red: 0.2349999994, green: 0.2349999994, blue: 0.2349999994, alpha: 1), icon: UIImage(named: "info_blue_icon_modal")!)
	}
	
	
	@IBAction func likeBtnPressed(_ sender: UIButton) {
		let post_id = sender.tag
		if let post = posts.first(where: {$0[AQ.fields.id] as? Int ?? 0 == post_id}) {
			if let likesObject = post[AQ.fields.likes] as? [String: Any?] {
				let wasLiked = (likesObject[AQ.fields.isLiked] as? Int ?? 0) == 1
				let isLiked = !wasLiked
				let oldCount = likesObject[AQ.fields.userLikesCount] as? Int ?? 0
				var newCount = oldCount
				if isLiked {
					newCount += 1
				} else {
					newCount -= 1
				}
				
				let newPosts = posts.map {
					if($0[AQ.fields.id] as? Int ?? 0 == post_id) {
						var post = $0
						post[AQ.fields.likes] = [
							AQ.fields.isLiked: isLiked ? 1 : 0,
							AQ.fields.userLikesCount: newCount,
						]
						return post
					}
					else {
						return $0
					}
				} as [[String: Any?]]
				state[AQ.fields.items] = newPosts
				
				AQ.likePost(post_id: post_id, like: isLiked ? 1 : 0, failure: { (err) in
					let newPosts = self.posts.map {
						if($0[AQ.fields.id] as? Int ?? 0 == post_id) {
							var post = $0
							post[AQ.fields.likes] = [
								AQ.fields.isLiked: wasLiked ? 1 : 0,
								AQ.fields.userLikesCount: oldCount,
							]
							return post
						}
						else {
							return $0
						}
					} as [[String: Any?]]
					self.state[AQ.fields.items] = newPosts
					self.alert(title: NSLocalizedString("Ошибка", comment: ""), text: NSLocalizedString("Не удалось поставить лайк", comment: ""))
				}) { (resp) in
					if resp[AQ.fields.status] as? Int ?? 1 != 0 {
						let newPosts = self.posts.map {
							if($0[AQ.fields.id] as? Int ?? 0 == post_id) {
								var post = $0
								post[AQ.fields.likes] = [
									AQ.fields.isLiked: wasLiked ? 1 : 0,
									AQ.fields.userLikesCount: oldCount,
								]
								return post
							}
							else {
								return $0
							}
						} as [[String: Any?]]
						self.state[AQ.fields.items] = newPosts
						self.alert(title: NSLocalizedString("Ошибка", comment: ""), text: NSLocalizedString("Не удалось поставить лайк", comment: ""))
					}
				}
			}
		}
	}
	
	@IBAction func commentLikeBtnPressed(_ sender: UIButton) {
		if let likesObject = getLikesObjectForComment(id: sender.tag) {
			let wasLiked = (likesObject[AQ.fields.isLiked] as? Int ?? 0) == 1
			let isLiked = !wasLiked
			let oldCount = likesObject[AQ.fields.userLikesCount] as? Int ?? 0
			var newCount = oldCount
			if isLiked {
				newCount += 1
			} else {
				newCount -= 1
			}
			
			updateComment(id: sender.tag, likesObject: [
				AQ.fields.isLiked: isLiked ? 1 : 0,
				AQ.fields.userLikesCount: newCount
			])
			
			
			AQ.likeComment(comment_id: sender.tag, like: isLiked ? 1 : 0, failure: { (err) in
				self.updateComment(id: sender.tag, likesObject: [
					AQ.fields.isLiked: wasLiked ? 1 : 0,
					AQ.fields.userLikesCount: oldCount
				])
				
				self.alert(title: NSLocalizedString("Ошибка", comment: ""), text: NSLocalizedString("Не удалось поставить лайк", comment: ""))
			}) { (resp) in
				if resp[AQ.fields.status] as? Int ?? 1 != 0 {
					self.updateComment(id: sender.tag, likesObject: [
						AQ.fields.isLiked: wasLiked ? 1 : 0,
						AQ.fields.userLikesCount: oldCount
					])
					self.alert(title: NSLocalizedString("Ошибка", comment: ""), text: NSLocalizedString("Не удалось поставить лайк", comment: ""))
				}
			}
		}
	}
	
	@IBAction func expandCommentsBtnPressed(_ sender: UIButton) {
	}
	
	func deleteAllPostsFromState() {
		state[AQ.fields.posts] = []
	}
	
	func addPostsToState(newPosts: [[String: Any?]]) {
		let filteredNewPosts = newPosts.filter { testedNewPost in
			if let testPostId = testedNewPost[AQ.fields.id] as? Int {
				return posts.first {
					$0[AQ.fields.id] as? Int ?? 0 == testPostId
					} == nil
			} else {
				return false
			}
		}
		
		state[AQ.fields.posts] = posts + filteredNewPosts
	}
	
	func getLikesObjectForComment(id: Int) -> [String: Any?]? {
		for post in posts {
			if let commentsContainer = post[AQ.fields.comments] as? [String: Any?] {
				if let comments = commentsContainer[AQ.fields.items] as? [[String: Any?]] {
					for comment in comments {
						if comment[AQ.fields.id] as? Int ?? 0 == id {
							return comment[AQ.fields.likes] as? [String: Any?]
						}
						
						if let subcomments = comment[AQ.fields.comments] as? [[String: Any?]] {
							for subcomment in subcomments {
								if subcomment[AQ.fields.id] as? Int ?? 0 == id {
									return subcomment[AQ.fields.likes] as? [String: Any?]
								}
							}
						}
					}
				}
			}
		}
		return nil
	}
	
	func updateComment(id: Int, likesObject: [String: Any?]) {
		let newPosts = posts.map { post in
			var newPost = post
			
			if let commentsContainer = post[AQ.fields.comments] as? [String: Any?] {
				var newContainer = commentsContainer
				if let comments = commentsContainer[AQ.fields.items] as? [[String: Any?]] {
					newContainer[AQ.fields.items] = comments.compactMap({ comment in
						var newComment = comment
						if comment[AQ.fields.id] as? Int ?? 0 == id {
							newComment[AQ.fields.likes] = likesObject
						} else {
							if let subcomments = comment[AQ.fields.comments] as? [[String: Any?]] {
								newComment[AQ.fields.comments] = subcomments.map { subcomment in
									var newSubcomment = subcomment
									if  subcomment[AQ.fields.id] as? Int ?? 0 == id {
										newSubcomment[AQ.fields.likes] = likesObject
									}
									return newSubcomment
									} as [[String: Any?]]
							}
						}
						return newComment
					}) as [[String: Any?]]
				}
				newPost[AQ.fields.comments] = newContainer
			}
			
			return newPost
			} as [[String: Any?]]
		state[AQ.fields.items] = newPosts
	}
	
	func deleteCommentFromState(id: Int) {
		let newPosts = posts.map { post in
			var newPost = post
			if let commentsContainer = post[AQ.fields.comments] as? [String: Any?] {
				var newContainer = commentsContainer
				if let comments = commentsContainer[AQ.fields.items] as? [[String: Any?]] {
					newContainer[AQ.fields.items] = comments.compactMap({ comment in
						if comment[AQ.fields.id] as? Int ?? 0 == id {
							return nil
						} else {
							var newComment = comment
							if let subcomments = comment[AQ.fields.comments] as? [[String: Any?]]{
								newComment[AQ.fields.comments] = subcomments.filter { subcomment in
									return subcomment[AQ.fields.id] as? Int ?? 0 != id
									} as [[String: Any?]]
							}
							return newComment
						}
					}) as [[String: Any?]]
				}
				newPost[AQ.fields.comments] = newContainer
			}
			
			return newPost
			} as [[String: Any?]]
		state[AQ.fields.items] = newPosts
	}
	
	
	func attachmentsArrayByAttachmentUniqueId(id: String?) -> [[String: Any?]]? {
		if id == nil {
			return nil
		}
		
		var attachmentPackages: [[[String: Any?]]] = []
		for post in posts {
			if let postContent = post[AQ.fields.postContent] as? [String: Any?]{
				if let attachments = postContent[AQ.fields.postContentAttachments] as? [[String: Any?]]{
					attachmentPackages.append(attachments)
				}
			}
			
			if let commentsContainer = post[AQ.fields.comments] as? [String: Any?] {
				if let comments = commentsContainer[AQ.fields.items] as? [[String: Any?]] {
					for comment in comments {
						if let postContent = comment[AQ.fields.postContent] as? [String: Any?]{
							if let attachments = postContent[AQ.fields.postContentAttachments] as? [[String: Any?]]{
								attachmentPackages.append(attachments)
							}
						}
						
						if let subcomments = comment[AQ.fields.comments] as? [[String: Any?]] {
							for subcomment in subcomments {
								if let postContent = subcomment[AQ.fields.postContent] as? [String: Any?]{
									if let attachments = postContent[AQ.fields.postContentAttachments] as? [[String: Any?]]{
										attachmentPackages.append(attachments)
									}
								}
							}
						}
					}
				}
			}
		}
		
		
		return attachmentPackages.first { package in
			let testAttachment = package.first { attachment in
				return attachment[AQ.fields.unique_id] as? String ?? "" == id
			}
			
			return testAttachment != nil
		}
	}
}

