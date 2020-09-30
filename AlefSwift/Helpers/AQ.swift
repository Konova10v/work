//
//  AlefQuery.swift
//  SwiftAlefQuery
//
//  Created by Станислав Гольденшлюгер
//  Copyright © 2020 Alef. All rights reserved.
//

import UIKit
import Foundation
import CommonCrypto

/*
	TUI Intanet 1.0 (https://intranet.alef.im/api/index.php)
	Сервер-прослойка для внутрикорпоративного мобильного приложения TUI Intranet 

[]
*/




typealias FailureBlockType = (Error) -> Void;
typealias SuccessBlockType = ([String: Any?]) -> Void;

class AQCache {
	static let ttls:[String: Int] = [
		"deleteAlbum": 0,
		"autocompleteUsers": 0,
		"repost": 0,
		"login": 0,
		"logout": 0,
		"getFeed": 0,
		"getMyProfile": 0,
		"addPost": 0,
		"editPost": 0,
		"deletePost": 0,
		"likePost": 0,
		"getComments": 0,
		"addComment": 0,
		"editComment": 0,
		"deleteComment": 0,
		"likeComment": 0,
		"getGroups": 0,
		"getUserGroups": 0,
		"addGroup": 0,
		"followGroup": 0,
		"editProfile": 0,
		"editMyMood": 0,
		"followUser": 0,
		"getNotificationCount": 0,
		"getNotifications": 0,
		"markNotificationAsRead": 0,
		"getUsersGroupMembers": 0,
		"getUsersStaff": 0,
		"getUsersFollowing": 0,
		"getUsersFollowers": 0,
		"getLikedByUsers": 0,
		"getAlbum": 0,
		"addAlbum": 0,
		"uploadAttachment": 0,
		"deleteAttachments": 0,
		"getCountries": 0,
		"search": 0
	];

	static var innerTableOfContents:[String: [String: Any]]?;
	static var tableOfContents:[String: [String: Any]] {
		get {
			if let innerTableOfContents = innerTableOfContents {
				return innerTableOfContents;
			}
			var toc:[String: [String: Any]] = [:];
			var filePath: URL? = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first;
			filePath?.appendPathComponent("cacheTableOfContents.dic");
			if let filePath = filePath {
				do {
					let archivedData = try Data(contentsOf: filePath);
					if let archived = NSKeyedUnarchiver.unarchiveObject(with: archivedData) as? [String: [String: Any]] {
						toc = archived;
					}
				} catch {

				}
			}
			innerTableOfContents = toc;
			return toc;
		}
		set (newToc){
			innerTableOfContents = newToc;
			var filePath: URL? = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first;
			filePath?.appendPathComponent("cacheTableOfContents.dic")
			if let filePath = filePath {
				let archivedData = NSKeyedArchiver.archivedData(withRootObject: newToc);
				do {
					try archivedData.write(to:filePath);
				} catch {

				}
			}
		}
	}

	static func loadFromCache(params: [String: Any]) -> String? {
		collectGarbage();
		let hash = AQ.SHA256(string: AQ.json(from: params)).map { String(format: "%02hhx", $0) }.joined();
		if let filePath = tableOfContents[hash]?["file"] as? String{
			do {
                var url: URL? = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first;
                url?.appendPathComponent(filePath);
                if let url = url {
                    return try String(contentsOf: url);
                }
			} catch {

			}
		}
		return nil;
	}

	static func saveToCache(params: [String: Any], resp: String) {
		guard let action = params["alef_action"] as? String else {
			return;
		}
		let ttl = ttls[action];
		if(ttl == 0) {
			return;
		}
		let timestamp = Date().timeIntervalSince1970;
		let hash = AQ.SHA256(string: AQ.json(from: params)).map { String(format: "%02hhx", $0) }.joined();

		var filePath: URL? = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first;
		filePath?.appendPathComponent(hash+".resp");
		if let action = params["alef_action"] {
			if let filePath = filePath {
				do {
					try resp.write(to: filePath, atomically: true, encoding: .utf8);

					var toc = tableOfContents;
					toc[hash] = [
						"timestamp": timestamp,
						"action": action,
						"file": hash+".resp"
					];

					tableOfContents = toc;
				}
				catch {

				}
			}
		}
	}

	static func clearAllCache() {
		for (_, info) in tableOfContents {

			if let filePath = info["file"] as? String{
				do {
					var url: URL? = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first;
					url?.appendPathComponent(filePath);
					if let url = url {
						try FileManager.default.removeItem(at: url);
					}
				} catch {

				}
			}
		}

		tableOfContents = [:];
	}

	private static func collectGarbage() {
		let cleanTime = Date().timeIntervalSince1970;
		var delete:[String] = [];
		for (hash, info) in tableOfContents {
			guard let action = info["action"] as? String, let timestamp = info["timestamp"] as? TimeInterval else {
				return;
			}

			let ttl = ttls[action] ?? 0;

			if (timestamp + Double(ttl) < cleanTime) {
				if let filePath = info["file"] as? String{
					do {
						var url: URL? = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first;
						url?.appendPathComponent(filePath);
						if let url = url {
							try FileManager.default.removeItem(at: url);
							delete.append(hash);
						}
					} catch {

					}
				}
			}
		}

		var toc = tableOfContents;
		for d in delete {
			toc.removeValue(forKey: d)
		}

		tableOfContents = toc;
	}
}

class AQ {
    static var serverURL = "https://intranet.alef.im/api/index.php";
	static var verbose = false;
	static var cacheEnabled = true;

	static func startMonitoringRadio() {
		updateRadio();
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateRadio), name: UIApplication.willEnterForegroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateRadio), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc static func updateRadio() {
		sendRequest(params: [
			"alef_action" : "getAlefRadio"
			],
					method: "get",
					errorBlock: { (err) in },
					successBlock: { (resp) in
						var url: URL? = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first;
						url?.appendPathComponent("AQRadio.json");
						if let radio = resp[self.fields.radio] as? [String: Any?] {
							let str = json(from: radio);
							if let url = url {
								do {
									try str.write(to: url, atomically: true, encoding: .utf8)
								}
								catch {

								}
							}
						}
					});
	}

	static let defaultRadioString = "{\"str\":\"str\", \"arr\":[1,2,3]}";
	static var radio : [String: Any] {
		do {
			var url: URL? = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first;
			url?.appendPathComponent("AQRadio.json");
			if let url = url {
				if let json = jsonToDictionary(data: Data(try String(contentsOf: url).utf8)) {
					return json;
				}
			}
		} catch {

		}

		return jsonToDictionary(data: Data(defaultRadioString.utf8))!
	}

	struct fields {
		static let radio = "radio";
		static let status = "status";
		static let users = "users";
		static let id = "id";
		static let avatarUrl = "avatarUrl";
		static let fullName = "fullName";
		static let positionName = "positionName";
		static let isOwnProfile = "isOwnProfile";
		static let isFollowedByMe = "isFollowedByMe";
		static let profile = "profile";
		static let isOnline = "isOnline";
		static let departmentName = "departmentName";
		static let phone = "phone";
		static let email = "email";
		static let dateOfBirth = "dateOfBirth";
		static let howCanHelp = "howCanHelp";
		static let mobilePhone = "mobilePhone";
		static let location = "location";
		static let mood = "mood";
		static let coinsCount = "coinsCount";
		static let socialUrls = "socialUrls";
		static let url = "url";
		static let socialTypeTxt = "socialTypeTxt";
		static let teamsAccount = "teamsAccount";
		static let albums = "albums";
		static let name = "name";
		static let coverPhotoUrl = "coverPhotoUrl";
		static let offset = "offset";
		static let count = "count";
		static let total = "total";
		static let hasMorePosts = "hasMorePosts";
		static let items = "items";
		static let createdTimeStamp = "createdTimeStamp";
		static let isOwn = "isOwn";
		static let replyWallPost = "replyWallPost";
		static let from = "from";
		static let groupId = "groupId";
		static let owner = "owner";
		static let likes = "likes";
		static let isLiked = "isLiked";
		static let userLikesCount = "userLikesCount";
		static let postContent = "postContent";
		static let text = "text";
		static let openGraphItem = "openGraphItem";
		static let type = "type";
		static let title = "title";
		static let description = "description";
		static let imageUrl = "imageUrl";
		static let originalUrl = "originalUrl";
		static let postContentAttachments = "postContentAttachments";
		static let unique_id = "unique_id";
		static let fileUrl = "fileUrl";
		static let mentions = "mentions";
		static let userId = "userId";
		static let startLetter = "startLetter";
		static let endLetter = "endLetter";
		static let comments = "comments";
		static let replyCommentId = "replyCommentId";
		static let fromAuthor = "fromAuthor";
		static let user = "user";
		static let group = "group";
		static let membersCount = "membersCount";
		static let isMember = "isMember";
		static let accessTypeStr = "accessTypeStr";
		static let isMandatory = "isMandatory";
		static let post = "post";
		static let comment = "comment";
		static let groups = "groups";
		static let subtitle = "subtitle";
		static let targetType = "targetType";
		static let targetId = "targetId";
		static let postId = "postId";
		static let previewUrl = "previewUrl";
		static let countries = "countries";
		static let posts = "posts";

    }

	
        static func deleteAlbum(id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Удалить альбом 
Удаление альбома
                ?alef_action=deleteAlbum
            */

            let params: [String:Any] = [
                "alef_action" : "deleteAlbum",
                        "id":(id), /* идентификатор ||| Пример значения: 159 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func autocompleteUsers(keyword: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Возвращает список сотрудников для упоминания в публикации или комменте 
                
            */

            let params: [String:Any] = [
                "alef_action" : "autocompleteUsers",
                        "keyword":keyword, /* строка фильтрации пользователей ||| Пример значения: Пров */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func repost(post_id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Репост 
Делает репост произвольной публикации в свою ленту
                
            */

            let params: [String:Any] = [
                "alef_action" : "repost",
                        "post_id":(post_id), /* id исходной публикации ||| Пример значения: 10 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func login(user_name: String, password: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Авторизация 
авторизация
                ?alef_action=login
            */

            let params: [String:Any] = [
                "alef_action" : "login",
                        "user_name":user_name, /* доменное имя пользователя ||| Пример значения: domain\\user.name */
                        "password":password, /* пароль ||| Пример значения: 123456 */
            ];
            
            sendRequest(params: params,
                    method: "post",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func logout(failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Разлогинивание 
                ?alef_action=logout
            */

            let params: [String:Any] = [
                "alef_action" : "logout",
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getFeed(user_id: Int, group_id: Int, offset: Int, limit: Int, search_query: String, created_ts_from: Int, created_ts_to: Int, forced_post_id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение ленты 
Получение ленты для пользователя или группы
                ?alef_action=getFeed
            */

            let params: [String:Any] = [
                "alef_action" : "getFeed",
                        "user_id":(user_id), /* Идентификатор пользователя ||| Пример значения: 12 */
                        "group_id":(group_id), /* Индентификатор группы ||| Пример значения: 54 */
                        "offset":(offset), /* Смещение поста для lazy loading ||| Пример значения: 0 */
                        "limit":(limit), /* Отсечение кол-ва возвращаемых результатов ||| Пример значения: 10 */
                        "search_query":search_query, /* Поисковая фраза ||| Пример значения: слово */
                        "created_ts_from":(created_ts_from), /* Дата (timestamp) с ||| Пример значения: 1600065836 */
                        "created_ts_to":(created_ts_to), /* Дата (timestamp) по ||| Пример значения: 1600165836 */
                        "forced_post_id":(forced_post_id), /* id публикации, которую обязательно необходимо включить в ленту ||| Пример значения: 25 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getMyProfile(failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение моего профиля 
Получение моего профиля
                ?alef_action=getMyProfile
            */

            let params: [String:Any] = [
                "alef_action" : "getMyProfile",
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func addPost(owner_user_id: Int, owner_group_id: Int, text: String, mentions: [Any], attachments: [Any], failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Создание нового поста 
                ?alef_action=addPost&text=hello&attachments=[{"id":1,"type":"video"},{"id":3,"type":"photo"}]
            */

            let params: [String:Any] = [
                "alef_action" : "addPost",
                        "owner_user_id":(owner_user_id), /* id пользователя (в случае публикации на стену пользователя). если оба параметра owner_ пустые, публикация происходит на стену текущего пользователя  ||| Пример значения: 32 */
                        "owner_group_id":(owner_group_id), /* id группы (в случае публикации на стену группы)  ||| Пример значения: 43 */
                        "text":text, /* Текст поста ||| Пример значения: Привет, @Имя Фамилия! Как дела? Какой-то текст */
                        "mentions": json(from: mentions), /* Список упоминаемых пользователей ||| Пример значения: [{"userId":1240,"startLetter":8,"endLetter":19}] */
                        "attachments": json(from: attachments), /* Список прикрепленных материалов ||| Пример значения: [{"id":1,"type":"video"},{"id":3,"type":"photo"}] */
            ];
            
            sendRequest(params: params,
                    method: "post",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func editPost(post_id: Int, text: String, mentions: [Any], attachments: [Any], failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Редактирование поста 
Редактирование поста
                ?alef_action=editPost&comment_id=10&text=hello&attachments=[{"id":1,"type":"video"},{"id":3,"type":"photo"}]
            */

            let params: [String:Any] = [
                "alef_action" : "editPost",
                        "post_id":(post_id), /* id поста ||| Пример значения: 10 */
                        "text":text, /* Текст поста ||| Пример значения: Привет, @Имя Фамилия! Как дела? Какой-то текст */
                        "mentions": json(from: mentions), /* Список упоминаемых пользователей ||| Пример значения: [{"userId":1240,"startLetter":8,"endLetter":19}] */
                        "attachments": json(from: attachments), /* Список прикрепленных материалов ||| Пример значения: [{"id":1,"type":"video"},{"id":3,"type":"photo"}] */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func deletePost(post_id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Удаление поста 
Удаление поста
                ?alef_action=deletePost&post_id=10
            */

            let params: [String:Any] = [
                "alef_action" : "deletePost",
                        "post_id":(post_id), /* id публикации ||| Пример значения: 10 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func likePost(post_id: Int, like: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Лайк поста 
                
            */

            let params: [String:Any] = [
                "alef_action" : "likePost",
                        "post_id":(post_id), /*  ||| Пример значения: 531 */
                        "like":(like), /* 1/0 like/unlike ||| Пример значения: 1 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getComments(post_id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение комментариев к посту 
                ?alef_action=getComments&post_id=32
            */

            let params: [String:Any] = [
                "alef_action" : "getComments",
                        "post_id":(post_id), /* id поста ||| Пример значения: 432 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func addComment(post_id: Int, reply_to_comment_id: Int, text: String, mentions: [Any], attachments: [Any], failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Создание нового комментария 
                ?alef_action=addComment&post_id=43&text=Something
            */

            let params: [String:Any] = [
                "alef_action" : "addComment",
                        "post_id":(post_id), /* id поста ||| Пример значения: 56 */
                        "reply_to_comment_id":(reply_to_comment_id), /* при ответе на комментарий – id комментария, в остальных случаях не передается ||| Пример значения: 43 */
                        "text":text, /* Текст комментария ||| Пример значения: Привет, @Имя Фамилия! Как дела? */
                        "mentions": json(from: mentions), /* Список упоминаемых пользователей ||| Пример значения: [{"userId":1240,"startLetter":8,"endLetter":19}] */
                        "attachments": json(from: attachments), /* Список прикрепленных материалов ||| Пример значения: [{"id":1,"type":"video"},{"id":3,"type":"photo"}] */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func editComment(comment_id: Int, text: String, mentions: [Any], attachments: [Any], failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Редактирование комментария 
Редактирование комментария
                ?alef_action=editComment&comment_id=10&text=Something_new
            */

            let params: [String:Any] = [
                "alef_action" : "editComment",
                        "comment_id":(comment_id), /* id комментария ||| Пример значения: 10 */
                        "text":text, /* Текст комментария ||| Пример значения: Привет, @Имя Фамилия! Как дела? */
                        "mentions": json(from: mentions), /* Список упоминаемых пользователей ||| Пример значения: [{"userId":1240,"startLetter":8,"endLetter":19}] */
                        "attachments": json(from: attachments), /* Список прикрепленных материалов ||| Пример значения: [{"id":1,"type":"video"},{"id":3,"type":"photo"}] */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func deleteComment(comment_id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Удаление комментария 
Удаление комментария
                ?alef_action=deleteComment&comment_id=10
            */

            let params: [String:Any] = [
                "alef_action" : "deleteComment",
                        "comment_id":(comment_id), /* id комментария ||| Пример значения: 10 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func likeComment(comment_id: Int, like: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Лайк комментария 
                ?alef_action=likeComment&comment_id=53&like=1
            */

            let params: [String:Any] = [
                "alef_action" : "likeComment",
                        "comment_id":(comment_id), /* id комментария ||| Пример значения: 432 */
                        "like":(like), /* 1/0 like/unlike ||| Пример значения: 1 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getGroups(country_id: Int, only_my_groups: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение списка групп для экрана групп 
 для экрана групп
                ?alef_action=getGroups
            */

            let params: [String:Any] = [
                "alef_action" : "getGroups",
                        "country_id":(country_id), /* Страны ||| Пример значения: 2 */
                        "only_my_groups":(only_my_groups), /* 1/0 Только мои группы / все группы ||| Пример значения: 1 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getUserGroups(user_id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение списка групп для фильтрации ленты 
для фильтрации ленты
                ?alef_action=getUserGroups
            */

            let params: [String:Any] = [
                "alef_action" : "getUserGroups",
                        "user_id":(user_id), /* id пользователя, для которого нужно получить список групп. Если указать 0 - все группы пользователя ||| Пример значения: 12 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func addGroup(name: String, description: String, wall_access_type: Int, wall_content_type: Int, avatar_photo_id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Создание группы 
                
            */

            let params: [String:Any] = [
                "alef_action" : "addGroup",
                        "name":name, /* Название ||| Пример значения: Моя группы */
                        "description":description, /* Описание ||| Пример значения: описание моей группы */
                        "wall_access_type":(wall_access_type), /* 1/2 открытая/закрытая ||| Пример значения: 1 */
                        "wall_content_type":(wall_content_type), /* 1/2 открытая/закрытая ||| Пример значения: 1 */
                        "avatar_photo_id":(avatar_photo_id), /* id фото для обложки ||| Пример значения: 31 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func followGroup(id: Int, follow: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Подписка на группу 
                ?alef_action=followGroup&follow=1
            */

            let params: [String:Any] = [
                "alef_action" : "followGroup",
                        "id":(id), /* id группы ||| Пример значения: 12 */
                        "follow":(follow), /* может быть 1/0 подписаться/отписаться ||| Пример значения: 1 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func editProfile(mobile_phone: String, location: String, how_can_help: String, fb_url: String, vk_url: String, twitter_url: String, instagram_url: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Редактирование профиля 
                alef_action=editProfile
            */

            let params: [String:Any] = [
                "alef_action" : "editProfile",
                        "mobile_phone":mobile_phone, /* Номер мобильного телефона ||| Пример значения: +79101113355 */
                        "location":location, /* Локация ||| Пример значения: Москва */
                        "how_can_help":how_can_help, /* Чем могу помочь ||| Пример значения: Умею чинить принтер */
                        "fb_url":fb_url, /* Ссылка на профиль в facebook ||| Пример значения: http://fb.com/11111 */
                        "vk_url":vk_url, /* Ссылка на профиль в vk ||| Пример значения: http://vk.com/11111 */
                        "twitter_url":twitter_url, /* Ссылка на профиль в twitter ||| Пример значения: http://twitter.com/11111 */
                        "instagram_url":instagram_url, /* Ссылка на профиль в instagram ||| Пример значения: http://instagram.com/11111 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func editMyMood(mood_text: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Редактирование настроения 
                ?alef_action=editMyMood&
            */

            let params: [String:Any] = [
                "alef_action" : "editMyMood",
                        "mood_text":mood_text, /* Текст настроения отображающийся в профиле пользователя ||| Пример значения: Hello world! */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func followUser(id: Int, follow: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Подписка на пользователя 
                
            */

            let params: [String:Any] = [
                "alef_action" : "followUser",
                        "id":(id), /* id пользователя ||| Пример значения: 333 */
                        "follow":(follow), /* может быть 1/0 подписаться/отписаться ||| Пример значения: 1 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getNotificationCount(failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение кол-ва нотификаций 
                
            */

            let params: [String:Any] = [
                "alef_action" : "getNotificationCount",
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getNotifications(failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение списка нотификаций 
                ?alef_action=getNotifications
            */

            let params: [String:Any] = [
                "alef_action" : "getNotifications",
            ];
            
            sendRequest(params: params,
                    method: "post",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func markNotificationAsRead(id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Пометка нотификации прочитанной 
                ?alef_action=markNotificationAsRead&id=831
            */

            let params: [String:Any] = [
                "alef_action" : "markNotificationAsRead",
                        "id":(id), /* id нотификации, если указать 0 - то все ||| Пример значения: 353 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getUsersGroupMembers(group_id: Int, search_query: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение списка участников группы 
                
            */

            let params: [String:Any] = [
                "alef_action" : "getUsersGroupMembers",
                        "group_id":(group_id), /* id группы ||| Пример значения: 31 */
                        "search_query":search_query, /* Поисковая фраза ||| Пример значения: Иван */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getUsersStaff(search_query: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение списка пользователей 
                
            */

            let params: [String:Any] = [
                "alef_action" : "getUsersStaff",
                        "search_query":search_query, /* Поисковая фраза ||| Пример значения: слово */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getUsersFollowing(seаrch_query: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение списка на кого подписан пользователь 
                ?alef_action=getUsersFollowing
            */

            let params: [String:Any] = [
                "alef_action" : "getUsersFollowing",
                        "seаrch_query":seаrch_query, /* Поисковая фраза ||| Пример значения: Иван */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getUsersFollowers(search_query: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение списка подписчиков пользователя 
                
            */

            let params: [String:Any] = [
                "alef_action" : "getUsersFollowers",
                        "search_query":search_query, /* Поисковая фраза ||| Пример значения: Иван */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getLikedByUsers(post_id: Int, comment_id: Int, search_query: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение списка лайкнувших пост или комментарий 
                
            */

            let params: [String:Any] = [
                "alef_action" : "getLikedByUsers",
                        "post_id":(post_id), /* id поста ||| Пример значения:  */
                        "comment_id":(comment_id), /* id коммента ||| Пример значения:  */
                        "search_query":search_query, /* Поисковая фраза ||| Пример значения: слово */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getAlbum(id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение содержимого альбома 
                alef_action=getAlbum&id=331
            */

            let params: [String:Any] = [
                "alef_action" : "getAlbum",
                        "id":(id), /*  ||| Пример значения: 37 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func addAlbum(name: String, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Создание альбома 
                ?alef_action=addAlbum&name=Новый
            */

            let params: [String:Any] = [
                "alef_action" : "addAlbum",
                        "name":name, /* Название альбома ||| Пример значения: Поездка на пикник */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func uploadAttachment(attachment: URL?, type: String, album_id: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Загрузка фото, видео или документа 
                ?alef_action=uploadAttachment&type=photo
            */

            var params: [String:Any] = [
                "alef_action" : "uploadAttachment",
                        "type":type, /* может принимать значения "photo", "video", "document" ||| Пример значения: photo */
                        "album_id":(album_id), /* id альбома, может быть пустым ||| Пример значения: 1 */
            ];
            
            if let attachment = attachment {
                params["attachment"] = attachment; /* Вложение  ||| Если нужно передать файл из памяти, а не с диска, то замените тип этого парметра на NSData */
            }
            
            sendRequest(params: params,
                    method: "post",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func deleteAttachments(ids: [Any], failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Удаление файлов и вложений 
                ?alef_action=deleteAttachments
            */

            let params: [String:Any] = [
                "alef_action" : "deleteAttachments",
                        "ids": json(from: ids), /* массив id объектов для удаления ||| Пример значения: {"photo_id":[1,2,3],"video_id":[1,2,3],"document_id":[1,2,3]} */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func getCountries(failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Получение списка стран 
                ?alef_action=getCountries
            */

            let params: [String:Any] = [
                "alef_action" : "getCountries",
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }
        static func search(search_query: String, include_posts: Int, include_groups: Int, include_users: Int, failure: @escaping FailureBlockType, success: @escaping SuccessBlockType) {
            /*
                Поиск 
                ?alef_action=search&search_query=test&include_posts=1&include_groups=1&include_users=0
            */

            let params: [String:Any] = [
                "alef_action" : "search",
                        "search_query":search_query, /* Поисковая фраза ||| Пример значения: TUI */
                        "include_posts":(include_posts), /* 1/0 искать посты ||| Пример значения: 1 */
                        "include_groups":(include_groups), /* 1/0 искать группы ||| Пример значения: 0 */
                        "include_users":(include_users), /* 1/0 искать пользователей ||| Пример значения: 0 */
            ];
            
            sendRequest(params: params,
                    method: "get",
                    errorBlock: failure,
                    successBlock: success);
        }

    static let notificationRequestFinished = "notificationRequestFinished";
    static let notificationRequestFailed = "notificationRequestFailed";

	static func SHA256(string: String) -> Data {
        let length = Int(CC_SHA256_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_SHA256(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }

    static private func paramString(params: Dictionary<String, Any>) -> String {
        var addr = "";

        for p in params {
            var text = "";
            if let val = p.value as? String{
                text = val;
            }

            if let val = p.value as? Int{
                text = String(val);
            }

            if let val = p.value as? Float{
                text = String(val);
            }

            text = text.replacingOccurrences(of: "&", with: "%26");
            addr += p.key + "=" + text + "&";
        }

        addr += "uncache=" + String(Int.random(in: 0...Int.max));
        addr = addr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? addr;
        addr = addr.replacingOccurrences(of: "%2526", with: "%26");
        addr = addr.replacingOccurrences(of: "/?", with: "?");
        addr = addr.replacingOccurrences(of: "+", with: "%2B");

        return addr;
    }

    static private func jsonToDictionary(data: Data) -> [String: Any]? {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                return nil
            }
    }

    static private func sendRequest(params: Dictionary<String, Any>, method: String, errorBlock: @escaping FailureBlockType, successBlock: @escaping SuccessBlockType) {
		if(verbose) {
			print("AlefQuery! Starting AQ request with params:");
			print ("AlefQuery! " + params.description);
		}

		if(cacheEnabled) {
			if let cachedResp = AQCache.loadFromCache(params: params), let resp = jsonToDictionary(data: Data(cachedResp.utf8)) {
				if(verbose) {
					print("AlefQuery! Got result from cache");
				}
				successBlock(resp);
				return;
			}
		}

        var decidedMethod = method;
        var securedParams = params;
        let timestamp = Int(Date.init().timeIntervalSince1970);
        securedParams["alef_security_timeout_timestamp"] = timestamp;
        var salted = "jolene-sulawesi" + String(timestamp);
        salted = SHA256(string: salted).map { String(format: "%02hhx", $0) }.joined();
        securedParams["alef_security_timeout_hash"] = salted;
		if(securedParams["lang"] == nil) {
			securedParams["lang"] = String(Locale.preferredLanguages[0].prefix(2));
		}

		if(verbose) {
			print("AlefQuery! Secured params:");
			print ("AlefQuery! " + securedParams.description);
		}

        var multipart = false;
        var fileDataDictionary: Dictionary<String, Dictionary<String, Any>> = [:];

        let nameKey = "nameKey";
        let typeKey = "typeKey";
        let objectKey = "objectKey";

        let requestFinish :(Data?, URLResponse?, Error?)->Void = {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in

			if(verbose) {
				print("AlefQuery! Received response");
			}
            if let error = error {
				if(verbose) {
					print("AlefQuery! Error in response");
					print("AlefQuery! " + error.localizedDescription);
				}
                DispatchQueue.main.async {
                    errorBlock(error);
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationRequestFailed), object: nil, userInfo: ["params":params, "error":error]);
                }
            }
            else {

                if let data = data, let json = jsonToDictionary(data: data) {
					if(verbose) {
						print("AlefQuery! Good response:");
						print("AlefQuery! " + json.description);
					}

					if (cacheEnabled) {
						let str = String(data: data, encoding: .utf8) ?? "";
						if let status = json[AQ.fields.status] as? Int {
							if status == 0 {
								AQCache.saveToCache(params: params, resp: str);
							}
						}
					}
                    DispatchQueue.main.async {
                        successBlock(json);
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationRequestFinished), object: nil, userInfo: ["params":params, "result":json]);
                    }

                }
                else {
                    var str = "";
                    if(data == nil) {
                        str = "";
                    }
                    else {
                        str = String(data: data!, encoding: .utf8) ?? "";
                    }

					if(verbose) {
						print("AlefQuery! Bad response:");
						print(str);
					}

                    let details = [
                            NSLocalizedDescriptionKey: "Server responce is not a valid JSON",
                            "request": serverURL + "?" + paramString(params: securedParams),
                            "response": str
                    ];

                    print("AlefQuery: " + details.description);

                    let jsonErr = NSError(domain: "JSONParse", code: 1, userInfo: details);
                    DispatchQueue.main.async {
                        errorBlock(jsonErr);
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationRequestFailed), object: nil, userInfo: ["params":params, "error":jsonErr]);
                    }
                }
            }
        }

        for p in securedParams {
            if let img = p.value as? UIImage {
                if let png = img.pngData() {
                    fileDataDictionary[p.key] = [
                        nameKey: p.key + ".png",
                        typeKey: "image/png",
                        objectKey: png
                    ];
                    multipart = true;
                    decidedMethod = "POST";
                }
            }

            if let data = p.value as? Data {
                fileDataDictionary[p.key] = [
                    nameKey: p.key,
                    typeKey: "text",
                    objectKey: data
                ];

                multipart = true;
                decidedMethod = "POST";
            }

            if let url = p.value as? URL {
                do {
                    let data = try Data(contentsOf: url)
                    fileDataDictionary[p.key] = [
                        nameKey: url.lastPathComponent,
                        typeKey: "text",
                        objectKey: data
                    ];

                    multipart = true;
                    decidedMethod = "POST";
                } catch {

                }
            }
        }


        if (multipart) {

			if(verbose) {
				print("AlefQuery! Multipart request");
			}

            let boundaryConstant = "----------V2ymHFg03ehbqgZCaKO6jy";
            var request = URLRequest(url: URL(string: serverURL)!);
            request.httpMethod = "POST";
            request.setValue("multipart/form-data; boundary=" + boundaryConstant, forHTTPHeaderField: "Content-Type");

            var body = Data();

            if(fileDataDictionary.count != 0) {
                for (key, obj) in fileDataDictionary {
                    body.append(("--" + boundaryConstant + "\r\n").data(using: .utf8)!);

                    let str = "Content-Disposition: form-data; name=\"" + key + "\"; filename=\""+(obj[nameKey] as! String)+"\"\r\n";
                    body.append((str).data(using: .utf8)!);
                    body.append(("Content-Type: " + (obj[typeKey] as! String) + "\r\n\r\n").data(using: .utf8)!);
                    body.append(obj[objectKey] as! Data);
                    body.append(("\r\n").data(using: .utf8)!);
                }

                body.append(("\n--" + boundaryConstant + "--\r\n").data(using: .utf8)!);
            }

            for (key, param) in securedParams {
                if (!(param is UIImage) && !(param is Data)  && !(param is URL))
                {
                    body.append(("--" + boundaryConstant + "\r\n").data(using: .utf8)!);
                    body.append(("Content-Disposition: form-data; name=\"" + key + "\"\r\n\r\n").data(using: .utf8)!);
                    if let param = param as? String {
                        body.append((param + "\r\n").data(using: .utf8)!);
                    }
                    if let param = param as? Int {
                        body.append((String(param) + "\r\n").data(using: .utf8)!);
                    }

                    if let param = param as? Float {
                        body.append((String(param) + "\r\n").data(using: .utf8)!);
                    }

                    if let param = param as? Double {
                        body.append((String(param) + "\r\n").data(using: .utf8)!);
                    }
                }
            }

            request.setValue(String(body.count), forHTTPHeaderField: "Content-Length");
            request.httpBody = body;

            let uploadTask = URLSession(configuration: .default).uploadTask(with: request, from: body, completionHandler: requestFinish);
            uploadTask.resume()
        }
        else
        {
			if(verbose) {
				print("AlefQuery! Regular request, not multipart");
			}
            if(decidedMethod.lowercased() == "get") {
				if(verbose) {
					print("AlefQuery! Method GET");
					print("AlefQuery! " + serverURL + "?" + paramString(params: securedParams).description);
				}
                let queryUrl = URL(string: serverURL + "?" + paramString(params: securedParams));
                let dataTask = URLSession.shared.dataTask(with: queryUrl!, completionHandler: requestFinish);
                dataTask.resume()
            }
            else {
				if(verbose) {
					print("AlefQuery! Method POST");
				}
                let queryUrl = URL(string: serverURL);
                var urlRequest = URLRequest(url: queryUrl!)
                let postParams = paramString(params: securedParams);
                let postData = postParams.data(using: .utf8);
                urlRequest.httpMethod = "POST";
                urlRequest.httpBody = postData;

                let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: requestFinish);
                dataTask.resume()
            }
        }

    }

	static func json(from object:Any) -> String {
		do {
			if JSONSerialization.isValidJSONObject(object) {
				let data = try JSONSerialization.data(withJSONObject: object, options: [])
				return String(data: data, encoding: String.Encoding.utf8) ?? "[]"
			} else {
				return "[]";
			}
		}
		catch {
			return "[]";
		}
    }
}
