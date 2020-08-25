//
//  AddPostViewController.swift
//  BgPlatziTweets
//
//  Created by Bryan Andres Gomez Hernandez on 8/25/20.
//  Copyright © 2020 Bryan Andres Gomez Hernandez. All rights reserved.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift

class AddPostViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var openCameraButton: UIButton!
    
    
    // MARK: - IBActions
    @IBAction func addPostAction(){
        savePost()
    }
    
    @IBAction func openCameraAction() {
        openCamera()
    }
    
    @IBAction func dissmisAction(){
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func openCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
    }
    
    private func savePost(){
        guard let post_text = postTextView.text, !post_text.isEmpty else {
            NotificationBanner(title: "Error al crear el tweet", subtitle: "El campo del tweet esta vacio", style: .warning).show()
            return
        }
        let request = PostRequest(text: post_text, imageUrl: nil, videoUrl: nil, location: nil)
        
        SVProgressHUD.show()
        SN.post(endpoint: Endpoints.post, model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch response {
            case .success( _):
                NotificationBanner(subtitle: "Tweet creado correctament.", style: .success).show()
                SVProgressHUD.dismiss()
                self.dismiss(animated: true, completion: nil)
                return
            case .error(let error):
                NotificationBanner(subtitle: error.localizedDescription, style: .danger).show()
                SVProgressHUD.dismiss()
                return
            case .errorResult(let entity):
                NotificationBanner(subtitle: entity.error, style: .warning).show()
                SVProgressHUD.dismiss()
                return
            }
        }
    }

}
// MARK: - UIImagePickerControllerDelegate
extension AddPostViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //Cerrar picker
        imagePicker?.dismiss(animated: true, completion: nil)
        if info.keys.contains(.originalImage){
            previewImageView.isHidden = false
            // obtenemos la imgen seleccionada
            previewImageView.image = info[.originalImage] as? UIImage
        }
    }
}
