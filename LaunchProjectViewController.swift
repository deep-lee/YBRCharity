//
//  LaunchProjectViewController.swift
//  YBRCharity
//
//  Created by 李冬 on 16/1/28.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import SwiftyDrop
import Alamofire
import SwiftyJSON

class LaunchProjectViewController: WPEditorViewController {

	var videoPressCache: NSCache = NSCache()
	var mediaAdded: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.delegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/**
	 进入下一个页面填写详细资料

	 - parameter sender:
	 */
	@IBAction func next(sender: AnyObject) {
		if editorView.titleField.html().isEmpty || editorView.contentField.html().isEmpty {
			Drop.down("请完成项目详情输入", state: DropState.Warning)
			return
		}

		// 进入下一个界面
		let launchProjectSecondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LaunchProjectSecondViewController") as! LaunchProjectSecondViewController
		self.navigationController?.pushViewController(launchProjectSecondViewController, animated: true)
	}
	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */

	// 显示图片选择器
	func showPhotoPicker() {
		let picker = UIImagePickerController()
		picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		picker.delegate = self
		picker.allowsEditing = false
		picker.navigationBar.translucent = false
		picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
		picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(picker.sourceType)!
		self.navigationController?.presentViewController(picker, animated: true, completion: nil)
	}

	// 添加资源到编辑器中
	func addAssetToContent(assertURL: NSURL) {
		let assets = PHAsset.fetchAssetsWithALAssetURLs([assertURL], options: nil)
		if assets.count < 1 {
			return
		}
		let asset = assets.firstObject as! PHAsset
		if asset.mediaType == PHAssetMediaType.Video {
			self.addVideoAssetToContent(asset)
		} else if asset.mediaType == PHAssetMediaType.Image {
			self.addImageAssetToContent(asset)
		}
	}

	// 添加视频
	func addVideoAssetToContent(originalAsset: PHAsset) {
		let options = PHImageRequestOptions()
		options.synchronous = false
		options.networkAccessAllowed = true
		options.resizeMode = PHImageRequestOptionsResizeMode.Fast
		options.version = PHImageRequestOptionsVersion.Current
		options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
		let videoID = NSUUID().UUIDString
		let videoPath = "\(NSTemporaryDirectory())\(videoID).mov"
		PHImageManager.defaultManager().requestImageForAsset(originalAsset, targetSize: UIScreen.mainScreen().bounds.size, contentMode: PHImageContentMode.AspectFit, options: options) { (image, info) -> Void in
			let data = UIImageJPEGRepresentation(image!, 0.7)
			let posterImagePath = "\(NSTemporaryDirectory())/\(NSUUID().UUIDString).jpg"
			data?.writeToFile(posterImagePath, atomically: true)
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.editorView.insertInProgressVideoWithID(videoID, usingPosterImage: NSURL.fileURLWithPath(posterImagePath).absoluteString)

				// 上传视频
				let progress = NSProgress(parent: nil, userInfo: [
					"videoID": videoID,
					"url": videoPath,
					"poster": posterImagePath
				])
				progress.cancellable = true
				Alamofire.upload(.POST, AppDelegate.URL_PREFEX + "accept_video.php", data: NSData(contentsOfFile: videoPath)!)
					.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
						progress.totalUnitCount = totalBytesExpectedToWrite
						progress.completedUnitCount = totalBytesWritten
						print(progress.fractionCompleted)

						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							self.editorView.setProgress(progress.fractionCompleted, onVideo: videoID)
							self.mediaAdded[videoID] = progress
						})
				}
					.responseJSON { response in
						print(response)
						// 返回的不为空
						if let value = response.result.value {
							// 解析json
							let json = JSON(value)
							let code = json["code"].intValue

							print(json)

							// 获取成功
							if code == 200 {
								let data = json["data"].stringValue
								let url = AppDelegate.URL_PREFEX + data
								self.editorView.replaceLocalVideoWithID(videoID, forRemoteVideo: url, remotePoster: posterImagePath, videoPress: videoID)

								self.videoPressCache.setObject([
									"source": url,
									"poster": posterImagePath
									], forKey: videoID)
							}
						}
				}
			})

//			let videoOptions = PHVideoRequestOptions()
//			videoOptions.networkAccessAllowed = true
//			PHImageManager.defaultManager().requestExportSessionForVideo(originalAsset, options: videoOptions, exportPreset: AVAssetExportPresetPassthrough, resultHandler: { (exportSession, info) -> Void in
//				exportSession?.outputFileType = kUTTypeQuickTimeMovie as String
//				exportSession?.shouldOptimizeForNetworkUse = true
//				exportSession?.outputURL = NSURL(fileURLWithPath: videoPath)
//				exportSession?.exportAsynchronouslyWithCompletionHandler({ () -> Void in
//					if exportSession?.status != AVAssetExportSessionStatus.Completed {
//						return;
//					}
//					dispatch_async(dispatch_get_main_queue(), { () -> Void in
//						let progress = NSProgress(parent: nil, userInfo: [
//							"videoID": videoID,
//							"url": videoPath,
//							"poster": posterImagePath
//						])
//
//						progress.cancellable = true
//						progress.totalUnitCount = 100
//						NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timerFireMethod:", userInfo: progress, repeats: true)
//						self.mediaAdded[videoID] = progress
//					})
//				})
//			})
		}
	}

	// 添加照片
	func addImageAssetToContent(asset: PHAsset) {
		let options = PHImageRequestOptions()
		options.synchronous = false
		options.networkAccessAllowed = true
		options.resizeMode = PHImageRequestOptionsResizeMode.Exact
		options.version = PHImageRequestOptionsVersion.Current
		options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
		let imageID = NSUUID().UUIDString
		let path = "\(NSTemporaryDirectory())/\(imageID).jpg"
		PHImageManager.defaultManager().requestImageDataForAsset(asset, options: options) { (imageData, dataUTI, orientation, info) -> Void in
			imageData?.writeToFile(path, atomically: true)
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.editorView.insertLocalImage(NSURL(fileURLWithPath: path).absoluteString, uniqueId: imageID)

				let image = UIImage(contentsOfFile: path)
				let progress = NSProgress(parent: nil, userInfo: ["imageID": imageID, "url": path])
				progress.cancellable = true
				Alamofire.upload(.POST, AppDelegate.URL_PREFEX + "accept_image.php", data: UIImageJPEGRepresentation(image!, 1)!)
					.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in

						progress.totalUnitCount = totalBytesExpectedToWrite
						progress.completedUnitCount = totalBytesWritten

						print(progress.fractionCompleted)

						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							self.editorView.setProgress(progress.fractionCompleted, onImage: imageID)
//							if progress.fractionCompleted >= 1 {
//								self.editorView.replaceLocalImageWithRemoteImage(NSURL(fileURLWithPath: progress.userInfo["url"] as! String).absoluteString, uniqueId: imageID)
//							}

							self.mediaAdded[imageID] = progress
						})
				}
					.responseJSON { response in
						print(response)
						// 返回的不为空
						if let value = response.result.value {
							// 解析json
							let json = JSON(value)
							let code = json["code"].intValue

							print(json)

							// 获取成功
							if code == 200 {
								let data = json["data"].stringValue
								let url = AppDelegate.URL_PREFEX + data
								self.editorView.replaceLocalImageWithRemoteImage(url, uniqueId: imageID)
							}
						}
				}
			})
		}

//		let progress = NSProgress(parent: nil, userInfo: ["imageID": imageID, "url": path])
//		progress.cancellable = true
//		progress.totalUnitCount = 100
//		let timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timerFireMethod:", userInfo: progress, repeats: true)
//
//		progress.cancellationHandler = { () -> Void in
//			timer.invalidate()
//		}
//
//		self.mediaAdded[imageID] = progress
	}

	func timerFireMethod(timer: NSTimer) {
		print("调用了")
		let progress = timer.userInfo as! NSProgress
		progress.completedUnitCount++
		let imageID = progress.userInfo["imageID"] as! String?
		if (imageID != nil) {
			self.editorView.setProgress(progress.fractionCompleted, onImage: imageID)
			if progress.fractionCompleted >= 1 {
				self.editorView.replaceLocalImageWithRemoteImage(NSURL(fileURLWithPath: progress.userInfo["url"] as! String).absoluteString, uniqueId: imageID)
				timer.invalidate()
			}

			return
		}

		let videoID = progress.userInfo["videoID"] as! String?
		if (videoID != nil) {
			self.editorView.setProgress(progress.fractionCompleted, onVideo: videoID)
			if progress.fractionCompleted >= 1 {
				let videoURL = NSURL(fileURLWithPath: progress.userInfo["url"] as! String).absoluteString
				let posterURL = NSURL(fileURLWithPath: progress.userInfo["poster"] as! String).absoluteString
				self.editorView.replaceLocalVideoWithID(videoID, forRemoteVideo: videoURL, remotePoster: posterURL, videoPress: videoID)
				self.videoPressCache.setObject([
					"source": videoURL,
					"poster": posterURL
					], forKey: videoID!)
				timer.invalidate()
			}

			return
		}
	}
}

extension LaunchProjectViewController: WPEditorViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	// 开始编辑
	func editorDidBeginEditing(editorController: WPEditorViewController!) {
		print("Editor did begin editing.")
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
			let assetURL = info[UIImagePickerControllerReferenceURL] as! NSURL
			print(assetURL)
			self.addAssetToContent(assetURL)
		})
	}

	// 添加图片
	func editorDidPressMedia(editorController: WPEditorViewController!) {
		self.showPhotoPicker()
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
