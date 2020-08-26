//
//  HomeViewController.swift
//  BgPlatziTweets
//
//  Created by Bryan Andres Gomez Hernandez on 8/25/20.
//  Copyright © 2020 Bryan Andres Gomez Hernandez. All rights reserved.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import AVKit

class HomeViewController: UIViewController {
    // MARK: - IBOutles
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let cellId = "TweetTableViewCell"
    private var dataSource = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        getPosts()
    }
    func setupUI(){
        //1. Asignar datasource
        tableView.dataSource = self
        
        //2. Registrar celda
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        
        //3. delegar table
        tableView.delegate = self
    }
    
    private func getPosts() {
        // 1. Inicio de carga
        SVProgressHUD.show()
        // 2. Consumir el servicio
        SN.get(endpoint: Endpoints.getPosts) { (response: SNResultWithEntity<[Post],ErrorResponse>) in
            switch response {
            case .success(let posts):                
                self.dataSource = posts
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                
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
    
    private func deletePostAt(indexPath: IndexPath) {
        //1. indicar carga al usuario
        SVProgressHUD.show()
        
        //2. obtener post id para borrar
        let postId = dataSource[indexPath.row].id
        
        //3.Consumir el servicio para eliminar el post
        let endpoint = Endpoints.delete + postId
        
        //4. consumir el servicio
        SN.delete(endpoint: endpoint) { (response: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch response {
            case .success( _):
                
                self.dataSource.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
                return
            case .error(let error):
                NotificationBanner(subtitle: error.localizedDescription, style: .danger).show()
                
                return
            case .errorResult(let entity):
                NotificationBanner(subtitle: entity.error, style: .warning).show()
                
                return
            }
        }
    }

}
//3. Configurar la celda deseadda
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Borrar") { (_, _) in
            //Borramos el tweet
            self.deletePostAt(indexPath: indexPath)
        }
        return [deleteAction]
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dataSource[indexPath.row].author.email == "papas@fritas.com"
    }

}

//3. Configurar la celda deseadda
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? TweetTableViewCell {
            cell.setUpCellWith(post: dataSource[indexPath.row])
            cell.needsToShowVideo = { url in
                // Aqui si deberiamos abrir un view controller
            
                let avPlayer = AVPlayer(url: url)
                let avPlayerController = AVPlayerViewController()
                avPlayerController.player = avPlayer
                self.present(avPlayerController, animated: true) {
                    avPlayerController.player?.play()
                }
            }
        }
        return cell
    }
    
    
}

extension HomeViewController {
    // Este metodo se llamara cuando hagamos transiciones entre pantallas pero solo con storyboards
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //1. Validar que el segue sea el esperado
        if segue.identifier == "showMap", let mapViewController = segue.destination as? MapaViewController {
            mapViewController.posts = dataSource.filter { $0.hasLocation }
        }
    }
}
