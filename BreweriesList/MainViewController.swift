//
//  ViewController.swift
//  BreweriesList
//
//  Created by DimMac on 14.12.2023.
//

import UIKit
import SQLite
import Network

protocol ShowOnMap: AnyObject {
    func didselect(breweryId: String)
}

struct Constants {
    static let mainColor: CGColor = CGColor(red: 45/255.0, green: 136/255.0, blue: 3/255.0, alpha: 1)
    static let url = "https://api.openbrewerydb.org/breweries"
}

class MainViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noBreweriesInfo: UIView!
    @IBOutlet weak var beerManImage: UIImageView!
    
    var db: BreweryDataBase?
    var allBreweries: [Brewery] = [] {
        didSet {
            self.breweriesToShow = allBreweries
        }
    }
    var isSearching = false
    var breweriesToShow: [Brewery] = []
    let monitor = NWPathMonitor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.searchTextField.backgroundColor = .white
        
        self.noBreweriesInfo.isHidden = true
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        db = BreweryDataBase.shared
        self.getBreweries(with: Constants.url)
        self.tableView.keyboardDismissMode = .onDrag
        self.dismissKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navigationItem.title = "Breweries"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func getBreweries(with url: String) {
        guard let url = URL(string: url) else {return}
        if NetworkMonitor.shared.isConnected {
            self.fetchBreweries(url: url)
        } else {
            self.allBreweries = self.db?.retrieveBreweries() ?? []
            self.tableView.reloadData()
            self.fetchBreweries(url: url)
        }
    }
    
    private func fetchBreweries(url: URL){
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            DispatchQueue.main.async {
                guard error == nil, let data = data else {
                    print("No data received:", error ?? URLError(.badServerResponse))
                    return
                }
                
                do {
                    let breweries = try JSONDecoder().decode([Brewery].self, from: data)
                    
                    if self.isSearching {
                        self.breweriesToShow = breweries
                        self.tableView.reloadData()
                    } else {
                        self.allBreweries = breweries
                        self.tableView.reloadData()
                        DispatchQueue.global(qos: .background).async{
                            self.db?.updateDB(with: breweries)
                        }
                    }
                    
                    self.noBreweriesInfo.isHidden = self.breweriesToShow.isEmpty ? false : true
                    if !breweries.isEmpty {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }
                    
                } catch let parseError {
                    print("Parsing error:", parseError, String(describing: String(data: data, encoding: .utf8)))
                }
            }
        }
        task.resume()
    }
    
    private func searchForBrewery(searchText: String){
        var components = URLComponents(string: Constants.url)
        components?.queryItems = [URLQueryItem(name: "by_name", value: searchText)]
        
        if searchText.isEmpty {
            self.breweriesToShow = self.allBreweries
            tableView.reloadData()
        } else {
            if NetworkMonitor.shared.isConnected {
                guard let searchURL = components?.url else {
                    print("Unable to build URL")
                    return
                }
                fetchBreweries(url: searchURL)
            } else {
                self.breweriesToShow = allBreweries.filter {$0.name.lowercased().contains(searchText.lowercased())}
                tableView.reloadData()
            }
        }
        
        if !self.breweriesToShow.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        self.noBreweriesInfo.isHidden = self.breweriesToShow.isEmpty ? false : true
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        breweriesToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BreweryTableCell
        let brewery = self.breweriesToShow[indexPath.row]
        cell.delegate = self
        cell.setup(brewery: brewery)
        return cell
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearching = true
        self.searchForBrewery(searchText: searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension MainViewController: ShowOnMap {
    func didselect(breweryId: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mapView = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else {return}
        mapView.selectedBrewery = breweriesToShow.filter {$0.id == breweryId}.first
        self.navigationController?.pushViewController(mapView, animated: true)
    }
}

extension UIViewController {
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}
