//
//  ViewController.swift
//  pokemonGo
//
//  Created by Fellipe Ricciardi Chiarello on 28/08/19.
//  Copyright © 2019 Fellipe Ricciardi Chiarello. All rights reserved.
//

import UIKit
import MapKit
import CoreData



class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapa: MKMapView!
    var gerenciadorLocalizacao = CLLocationManager()
    var contador = 0
    var coreDataPokemon: CoreDataPokemon!
    var pokemons: [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapa.delegate = self
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
        
        //Recuperar Pokemons
        
        self.coreDataPokemon = CoreDataPokemon()
        self.pokemons = self.coreDataPokemon.recuperarTodosPokemons()
        
        
        //Exibir Pokemons
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            if let coordenadas = self.gerenciadorLocalizacao.location?.coordinate{
               
                let totalPokemons = UInt32(self.pokemons.count)
                let indicePokemonAleatorio = arc4random_uniform(totalPokemons)
               
                let pokemom = self.pokemons[Int(indicePokemonAleatorio)]
                
                let anotacao = PokemonAnotacao(coordenadas: coordenadas, pokemon: pokemom)
                let latAleatoria = (Double(arc4random_uniform(500)) - 250 )  / 100000.0
                let longAleatoria = (Double(arc4random_uniform(500)) - 250 )  / 100000.0

                anotacao.coordinate.latitude += latAleatoria
                anotacao.coordinate.longitude += longAleatoria
                
                self.mapa.addAnnotation(anotacao)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let anotacaoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
       
        
        if annotation is MKUserLocation{
            anotacaoView.image = UIImage(named: "player")
        }else{
            let anot = annotation as! PokemonAnotacao
            print(anot.pokemon.nome!)
            anotacaoView.image = UIImage(named: anot.pokemon.nomeImagem!)
        }
       
        var frame = anotacaoView.frame
        frame.size.height = 40
        frame.size.width = 40
        
        anotacaoView.frame = frame
        
        
        
        return anotacaoView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let anotacao = view.annotation
        guard let annotation = view.annotation as? PokemonAnotacao,
        let pokemon = annotation.pokemon as? Pokemon,
        let name = pokemon.nome as? String else {
            return
        }
       
        mapView.deselectAnnotation(anotacao, animated: true)
        
        if anotacao is MKUserLocation {
            return
        }
         if let coordAnotacao = anotacao?.coordinate{
            let regiao = MKCoordinateRegion(center: coordAnotacao,latitudinalMeters: 300, longitudinalMeters: 300)
            mapa.setRegion(regiao, animated: true)
        }
       
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            if let coord = self.gerenciadorLocalizacao.location?.coordinate {
                if self.mapa.visibleMapRect.contains(MKMapPoint.init(coord)){
                    self.coreDataPokemon.salvarPokemon(pokemon: pokemon)
                    self.mapa.removeAnnotation(anotacao!)
                    let alertController = UIAlertController(title: "Parabéns!", message: "Você capturou o Pokemón, \(name)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    let alertController = UIAlertController(title: "Quase!", message: "Você está muito distante para capturar esse Pokemón!", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
        }

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if contador < 3 {
            
            self.centralizar()
            
            contador += 1
        }else{
            gerenciadorLocalizacao.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse && status != .notDetermined {
            let alertController = UIAlertController(title: "Acesso Localizacao!!", message: "Precisamos acessar sua localização para que você possa caçar Pokémons!", preferredStyle: .alert)
            let acaoConfiguracoes = UIAlertAction(title: "Abrir Configurações?", style: .default) { (alertaConfiguracoes) in
                if let configuracoes = NSURL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(configuracoes as URL)
                }}
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            
            alertController.addAction(acaoConfiguracoes)
            alertController.addAction(acaoCancelar)
            
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func centralizar (){
        if let coordenadas = gerenciadorLocalizacao.location?.coordinate{
            let regiao = MKCoordinateRegion(center: coordenadas,latitudinalMeters: 300, longitudinalMeters: 300)
            mapa.setRegion(regiao, animated: true)
        }
    }
    

    @IBAction func centralizaUsuario(_ sender: Any) {
        self.centralizar()
    }
    
    
    @IBAction func abrirPokedex(_ sender: Any) {
    }
    
}

