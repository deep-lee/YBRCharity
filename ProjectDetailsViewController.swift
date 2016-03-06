//
//  ProjectDetailsViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/1/30.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import SwiftyDrop
import Alamofire
import SwiftyJSON

class ProjectDetailsViewController: WPEditorViewController {

	var videoPressCache: NSCache = NSCache()
	var mediaAdded: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()

	var projectId: Int?
	var project: Project?
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.delegate = self
		self.project = Project()

		self.queryProjectDetails()
	}

	/**
	 查询项目的详细信息
	 */
	func queryProjectDetails() {
		SVProgressHUD.show()

		let paras = [
			"id": projectId!
		]
		Alamofire.request(.GET, AppDelegate.URL_PREFEX + "get_specific_project.php", parameters: paras)
			.responseJSON { response in

				// 返回的不为空
				if let value = response.result.value {
					// 解析json
					let json = JSON(value)
					let code = json["code"].intValue

					print(json)

					// 获取成功
					if code == 200 {
						let data = json["data"]
						self.project?.id = data["id"].intValue
						self.project?.launcher_id = data["launcher_id"].intValue
						self.project?.launch_time = data["launch_time"].stringValue
						self.project?.project_title = data["project_title"].stringValue
						self.project?.details_page = data["details_page"].stringValue
						self.project?.recipient_real_id = data["recipient_real_id"].stringValue
						self.project?.recipient_real_name = data["recipient_real_name"].stringValue
						self.project?.recipient_address = data["recipient_address"].stringValue
						self.project?.project_type = data["project_type"].intValue
						self.project?.amount_for_help = data["amount_for_help"].intValue
						self.project?.depositary_bank = data["depositary_bank"].stringValue
						self.project?.bank_account = data["bank_account"].stringValue
						self.project?.status = data["status"].intValue
						self.project?.has_donated_amount = data["has_donated_amount"].intValue
						// 更新界面
						self.updateEditorView()
					} else {
						Drop.down("获取数据失败，" + AppDelegate.TRY_AGAIN, state: DropState.Error)
					}
				} else {
					Drop.down("获取数据失败，" + AppDelegate.NETWORK_ERROR, state: DropState.Error)
				}

				SVProgressHUD.dismiss()
		}
	}

	func updateEditorView() {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			self.editorView.titleField.setText(self.project?.project_title)
			var contentHtml: String?
			do {
				try contentHtml = NSString(contentsOfURL: NSURL(string: (self.project?.details_page)!)!, encoding: NSUTF8StringEncoding) as String
			} catch {
			}

			self.editorView.contentField.setHtml(contentHtml)
			self.editorView.titleField.disableEditing()
			self.editorView.contentField.disableEditing()
		}
	}

	@IBAction func moreInfoAction(sender: AnyObject) {
		let moreInfoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MoreInfoViewController") as! MoreInfoViewController
		moreInfoViewController.project = self.project
		self.navigationController?.pushViewController(moreInfoViewController, animated: true)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
}

extension ProjectDetailsViewController: WPEditorViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	// 开始编辑
	func editorDidBeginEditing(editorController: WPEditorViewController!) {
		print("Editor did begin editing.")
//		self.editorView.titleField.disableEditing()
//		self.editorView.contentField.disableEditing()
	}

	// 结束编辑
	func editorDidEndEditing(editorController: WPEditorViewController!) {
		print("Editor did end editing.")
	}

	// 加载HTML结束
	func editorDidFinishLoadingDOM(editorController: WPEditorViewController!) {
		// let path = NSBundle.mainBundle().pathForResource("content", ofType: "html")
		// let htmlParam = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
		// self.titleText = "I'm editing a post!"
	}

	func editorShouldDisplaySourceView(editorController: WPEditorViewController!) -> Bool {
		self.editorView.pauseAllVideos()
		return true
	}

	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
		self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
//			let assetURL = info[UIImagePickerControllerReferenceURL] as! NSURL
//			print(assetURL)
//			self.addAssetToContent(assetURL)
		})
	}

	// 添加图片
	func editorDidPressMedia(editorController: WPEditorViewController!) {
		// self.showPhotoPicker()
	}

	func editorTitleDidChange(editorController: WPEditorViewController!) {
	}

	func editorTextDidChange(editorController: WPEditorViewController!) {
	}

	func editorViewController(editorViewController: WPEditorViewController!, fieldCreated field: WPEditorField!) {
	}

	// 点击图片
	func editorViewController(editorViewController: WPEditorViewController!, imageTapped imageId: String!, url: NSURL!, imageMeta: WPImageMeta) {
	}

	// 点击视频
	func editorViewController(editorViewController: WPEditorViewController!, videoTapped videoID: String!, url: NSURL!) {
	}

	func editorViewController(editorViewController: WPEditorViewController!, imageReplaced imageId: String!) {
		self.mediaAdded.removeValueForKey(imageId)
	}

	func editorViewController(editorViewController: WPEditorViewController!, videoReplaced videoID: String!) {
		self.mediaAdded.removeValueForKey(videoID)
	}

	func editorViewController(editorViewController: WPEditorViewController!, videoPressInfoRequest videoID: String!) {
		let videoPressInfo = self.videoPressCache.objectForKey(videoID) as! NSDictionary
		let videoURL = videoPressInfo["source"] as! String?
		let posterURL = videoPressInfo["poster"] as! String?

		if (videoURL != nil) {
			self.editorView.setVideoPress(videoID, source: videoURL, poster: posterURL)
		}
	}

	func editorViewController(editorViewController: WPEditorViewController!, mediaRemoved mediaID: String!) {
		let progress = self.mediaAdded[mediaID] as! NSProgress
		progress.cancel()
	}
}
