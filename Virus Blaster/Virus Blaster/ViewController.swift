//
//  ViewController.swift
//  Virus Blaster
//
//  Created by tallerapps on 13/04/2021.
//

import UIKit
import ARKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    @IBOutlet weak var botonRecolocarEscena: UIButton!
    
    @IBOutlet weak var botonReady: UIButton!
    
    
    // ARView, Tablero y Prototipos
    let superficiePlana = ARWorldTrackingConfiguration()
    
    var tableroJuego: VirusBlaster.EscenaPrincipal!
    
    // Controlador de Niveles y Fases
    enum modoDeJuego {
        case pausa, enPartida
    }
    var modoDeJuegoActual: modoDeJuego = .pausa
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        superficiePlana.planeDetection = .horizontal
        arView.session.run(superficiePlana)
        
        tableroJuego = try! VirusBlaster.loadEscenaPrincipal()
        arView.scene.anchors.append(tableroJuego)
    }
    
    @IBAction func empezarPartida(_ sender: Any) {
        botonReady.isHidden = true
        botonRecolocarEscena.isHidden = true
        
        modoDeJuegoActual = .enPartida
    }
    
    @IBAction func recolocarEscena(_ sender: Any) {
        arView.scene.anchors.removeAll()
        
        tableroJuego = try! VirusBlaster.loadEscenaPrincipal()
        arView.scene.anchors.append(tableroJuego)
    }
    
    
    
    
}
