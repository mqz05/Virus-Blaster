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
    
    // Botones e Imágenes de la interfaz
    @IBOutlet weak var botonRecolocarEscena: UIButton!
    
    @IBOutlet weak var botonReady: UIButton!
    
    @IBOutlet weak var corazonVida1: UIImageView!
    @IBOutlet weak var corazonVida2: UIImageView!
    @IBOutlet weak var corazonVida3: UIImageView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var panelScore: UIImageView!
    
    @IBOutlet weak var panelFinal: UIImageView!
    
    // ARView, Tablero y Prototipos
    let superficiePlana = ARWorldTrackingConfiguration()
    
    var tableroJuego: VirusBlaster.EscenaPrincipal!
    
    // Controlador de Niveles y Fases
    enum modoDeJuego {
        case pausa, enPartida, gameOver
    }
    var modoDeJuegoActual: modoDeJuego = .pausa
    
    var numeroDeVidas = 3
    
    var score = 0
    
    let posicionesPredeterminadasXZ = [SIMD2(x: 1.25, y: 0), SIMD2(x: 0.8, y: 0.8), SIMD2(x: 0, y: 1.25), SIMD2(x: -0.8, y: 0.8), SIMD2(x: -1.25, y: 0), SIMD2(x: -0.8, y: -0.8), SIMD2(x: 0, y: -1.25), SIMD2(x: 0.8, y: -0.8)]
    
    let posicionesPredeterminadasY = [0.25, 0.5, 0.75, 1]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        superficiePlana.planeDetection = .horizontal
        arView.session.run(superficiePlana)
        
        tableroJuego = try! VirusBlaster.loadEscenaPrincipal()
        arView.scene.anchors.append(tableroJuego)
        
        scoreLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 30)
        scoreLabel.text = "\(score)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if modoDeJuegoActual == .enPartida {
            guard let touchLocation = (touches.first?.location(in: arView)), let tappedEntity = arView.hitTest(touchLocation, query: .nearest, mask: .default).first?.entity else { return }
            
            if tappedEntity.name == "Virus" {
                tappedEntity.isEnabled = false
                tappedEntity.removeFromParent()
                
                score += 1
                scoreLabel.text = "\(score)"
            }
        } else if modoDeJuegoActual == .gameOver {
            arView.scene.anchors.removeAll()
            arView.session.pause()
            
            performSegue(withIdentifier: "Volver Pantalla Inicio", sender: nil)
        }
    }
    
    @IBAction func empezarPartida(_ sender: Any) {
        botonReady.isHidden = true
        botonRecolocarEscena.isHidden = true
        
        panelScore.isHidden = false
        scoreLabel.isHidden = false
        
        corazonVida1.isHidden = false
        corazonVida2.isHidden = false
        corazonVida3.isHidden = false
        
        modoDeJuegoActual = .enPartida
        
        generarVirus()
    }
    
    @IBAction func recolocarEscena(_ sender: Any) {
        arView.scene.anchors.removeAll()
        
        tableroJuego = try! VirusBlaster.loadEscenaPrincipal()
        arView.scene.anchors.append(tableroJuego)
    }
    
    func generarVirus() {
        if modoDeJuegoActual == .enPartida {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                self.crearPosicionarVirus()
                self.generarVirus()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.35, execute: {
                    for (index, valor) in self.tableroJuego.children.enumerated() {
                        if valor.name == "Virus" && (valor.position.x < 30 && valor.position.x > -30) && (valor.position.z < 30 && valor.position.z > -30) {
                            
                                // CHECK
                                
                                self.numeroDeVidas -= 1
                                
                            print("SI: \(valor.position)")
                                
                                self.tableroJuego.children[index].isEnabled = false
                                self.tableroJuego.children[index].removeFromParent()
                                
                                self.animacionBajarCorazonVida()
                        } else {
                            print("NO: \(valor.position)")
                        }
                    }
                })
            })
        }
    }
    
    func crearPosicionarVirus() {
        let virus = crearVirus()
        virus.name = "Virus"
        virus.generateCollisionShapes(recursive: true)
        
        virus.position = sacarPosicionRandom()
        
        tableroJuego.addChild(virus)
        
        var transform = Transform()
        transform.translation = SIMD3<Float>(x: 0, y: 0, z: 0)
        transform.scale = SIMD3(x: 0.005, y: 0.005, z: 0.005)
        //transform.rotation
        
        virus.move(to: transform, relativeTo: tableroJuego.sekilin, duration: 9, timingFunction: .linear)
    }
    
    func crearVirus() -> ModelEntity {
        var nuevoVirus: ModelEntity!
        let urlPath = Bundle.main.path(forResource: "Virus (Virus Blaster)", ofType: "usdz")
        let url = URL(fileURLWithPath: urlPath!)
        nuevoVirus = try? ModelEntity.loadModel(contentsOf: url)
        
        nuevoVirus.scale = SIMD3(x: 0.005, y: 0.005, z: 0.005)
        
        return nuevoVirus
    }
    
    func sacarPosicionRandom() -> SIMD3<Float> {
        let seleccionarPosicionPredeterminada = posicionesPredeterminadasXZ[Int.random(in: 0...7)]
        let posicionYRandom = posicionesPredeterminadasY[Int.random(in: 0...3)]
        
        let posicion: SIMD3<Float> = SIMD3<Float>(x: Float(seleccionarPosicionPredeterminada.x), y: Float(posicionYRandom), z: Float(seleccionarPosicionPredeterminada.y))
        
        return posicion
    }
    
    func animacionBajarCorazonVida() {
        if self.numeroDeVidas == 2 {
            self.corazonVida3.image = UIImage(named: "Vida Corazon Roto")
            
        } else if self.numeroDeVidas == 1 {
            self.corazonVida2.image = UIImage(named: "Vida Corazon Roto")
            
        } else if self.numeroDeVidas == 0 {
            self.corazonVida1.image = UIImage(named: "Vida Corazon Roto")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.animacionGamerOver()
            })
        }
    }
    
    func animacionGamerOver() {
        panelFinal.isHidden = false
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.panelFinal.transform = CGAffineTransform(scaleX: 12, y: 12)
        }, completion: { _ in self.modoDeJuegoActual = .gameOver })
    }
}
