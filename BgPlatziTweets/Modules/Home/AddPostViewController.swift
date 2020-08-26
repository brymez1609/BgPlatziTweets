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
import FirebaseStorage
import AVFoundation
import AVKit
import MobileCoreServices
import CoreLocation

class AddPostViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var openCameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func addPostAction(){
        uploadVideoPhotoToFirebase(type_content: type_content, ext: ext, folder_name: folder_name)
        if data == nil {
            savePost(videPhotoUrl: nil, photoUrl: nil)
        }
    }
    
    @IBAction func openCameraAction() {
        let alert = UIAlertController(title: "Camara", message: "Selecciona un opcion", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { (_) in
            self.openCamera()
            self.type_content = "image/jpg"
            self.ext = "jpg"
            self.folder_name = "fotos-tweets"
            
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { (_) in
            self.openVideoCamera()
            self.type_content = "video/mp4"
            self.ext = "mp4"
            self.folder_name = "video-tweets"
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        present(alert,animated: true,completion: nil)
    }
    
    @IBAction func openPreviewAction() {
        guard let currentVideoURL = currentVideoURL else {
            return
        }
        let avPlayer = AVPlayer(url: currentVideoURL)
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    
    @IBAction func dissmisAction(){
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoURL: URL?
    private var data: Data! = nil
    private var type_content: String! = ""
    private var ext: String! = ""
    private var folder_name: String! = ""
    private var locationManager: CLLocationManager?
    private var userLocation: CLLocation?
    
    override func viewDidLoad() {
        requestLocation()
        super.viewDidLoad()

    }
    
    private func requestLocation(){
        // Validamos que el usuario tenga el gps activo y disponible
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        
    }
    
    private func openVideoCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        present(imagePicker, animated: true, completion: nil)
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
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func uploadVideoPhotoToFirebase(type_content:String,ext:String,folder_name:String){
        //1. asegurarnos que el video exista
        switch type_content {
            case "video/mp4":
                guard let currentVideoSaveURL = currentVideoURL,
                //2. Comprimir el video y convertirlo en Data
                    let data: Data = try? Data(contentsOf: currentVideoSaveURL) else { return }
                self.data = data
            case "image/jpg":
                guard let imageSave = previewImageView.image,
                //2. Comprimir la imagen y convertirla en Data
                    let data: Data = imageSave.jpegData(compressionQuality: 0.1) else { return }
                self.data = data
            default:
                return
        }
        
        //. mostrar progress
        SVProgressHUD.show()
        //.3 Configuracion para guardar la foto en  firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = type_content
        
        //4. Referencia a Storage de firebase
        let storage = Storage.storage()
        
        //5. Crear nombre de la imagen a subir
        let videoName = Int.random(in: 100...1000)
        
        //6. Referencia a la carpeta donde se va a guardar la foto
        let folderReference = storage.reference(withPath: "\(folder_name)/\(videoName).\(ext)")
        
        //7. Subir la foto a firebase en un hilo secundario
        
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(self.data, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                DispatchQueue.main.async {
                    //Detener la cargar volviendo al hilo principal
                    SVProgressHUD.dismiss()
                    if let error = error {
                        NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .warning).show()
                        return
                    }
                }
                //Obtener la URL de descarga
                folderReference.downloadURL { (url: URL?, error: Error?) in
                    let downloadUrl = url?.absoluteString ?? ""
                    switch type_content {
                        case "video/mp4":
                            self.savePost(videPhotoUrl: downloadUrl, photoUrl:nil)
                        case "image/jpg":
                            self.savePost(videPhotoUrl: nil, photoUrl: downloadUrl)
                        default:
                            return
                    }
                }
            }
        }
        
    }
    
    
    private func savePost(videPhotoUrl: String?, photoUrl: String?){
        guard let post_text = postTextView.text, !post_text.isEmpty else {
            NotificationBanner(title: "Error al crear el tweet", subtitle: "El campo del tweet esta vacio o no hay contenido para subir", style: .warning).show()
            return
        }
        var postLocation: PostRequestLocation?
        if let userLocation = userLocation {
            postLocation = PostRequestLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        }
        
        let request = PostRequest(text: post_text, imageUrl: photoUrl, videoUrl: videPhotoUrl, location: postLocation)
        
        SVProgressHUD.show()
        SN.post(endpoint: Endpoints.post, model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch response {
            case .success( _):
                NotificationBanner(subtitle: "Tweet creado correctamente.", style: .success).show()
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
        
        //Capturar imagen
        if info.keys.contains(.originalImage){
            previewImageView.isHidden = false
            // obtenemos la imgen seleccionada
            previewImageView.image = info[.originalImage] as? UIImage
        }
        
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            videoButton.isHidden = false
            currentVideoURL = recordedVideoUrl
        }
    }
}

extension AddPostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let bestLocation = locations.last else {
            return
        }
        //Ya tenemos la ubicacion del usuario
        userLocation = bestLocation
    }
}
