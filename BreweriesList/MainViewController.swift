//
//  ViewController.swift
//  BreweriesList
//
//  Created by DimMac on 14.12.2023.
//

import UIKit
import SQLite
import Network

struct Constants {
    static let mainColor: CGColor = CGColor(red: 45/255.0, green: 136/255.0, blue: 3/255.0, alpha: 1)
    static let listURL = "https://api.openbrewerydb.org/breweries"
    static let searchURL = "https://api.openbrewerydb.org/breweries?by_name="
}

class MainViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noBreweriesInfo: UIStackView!
    
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
        getBreweries(with: Constants.listURL)
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
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let breweries = try? JSONDecoder().decode([Brewery].self, from: data) {
                    if self.isSearching {
                        DispatchQueue.main.async {
                            self.breweriesToShow = breweries
                            self.noBreweriesInfo.isHidden = self.breweriesToShow.isEmpty ? false : true
                            self.tableView.reloadData()
                            if !breweries.isEmpty {
                                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.allBreweries = breweries
                            self.noBreweriesInfo.isHidden = self.breweriesToShow.isEmpty ? false : true
                            self.tableView.reloadData()
                        }
                        self.db?.updateDB(with: breweries)
                    }
                } else {
                    print("Invalid response")
                }
            }
        }
        task.resume()
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        breweriesToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BreweryTableCell
        let brewery = self.breweriesToShow[indexPath.row]
        cell.setup(brewery: brewery)
        return cell
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearching = true
        let searchURL = Constants.searchURL + searchText
        if searchText.isEmpty {
            self.breweriesToShow = self.allBreweries
            tableView.reloadData()
            if !breweriesToShow.isEmpty {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        } else {
            guard let url = URL(string: searchURL) else {return}
            fetchBreweries(url: url)
        }
    }
}
