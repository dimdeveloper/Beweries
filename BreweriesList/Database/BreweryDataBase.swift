//
//  BreweryDataBase.swift
//  BreweriesList
//
//  Created by DimMac on 15.12.2023.
//

import SQLite
class BreweryDataBase {
    static let shared = BreweryDataBase()
    var dataBase: Connection?
    let breweriesTable = Table("brewerys")
    let id = Expression<String>("id")
    let name =  Expression<String>("name")
    let breweryType = Expression<String?>("brewery_type")
    let addres1 = Expression<String?>("address_1")
    let addres2 = Expression<String?>("address_2")
    let addres3 = Expression<String?>("address_3")
    let city = Expression<String?>("city")
    let stateProvince = Expression<String?>("state_province")
    let postalCode = Expression<String?>("postal_code")
    let country = Expression<String?>("country")
    let longtitude = Expression<String?>("longitude")
    let latitude = Expression<String?>("latitude")
    let phone = Expression<String?>("phone")
    let websiteUrl = Expression<String?>("website_url")
    let  state = Expression<String?>("state")
    let street  = Expression<String?>("street")
    let fileManager = FileManager.default
    let documentsDirectory: URL?
    var dbURL: String?
            
    private init(){
        documentsDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        guard let directory = self.documentsDirectory else {return}
        reviseDataBase(at: directory)
    }
    
    private func reviseDataBase(at url: URL) {
        do {
            var filePath: String
            if let path = dataBaseURL(url: url) {
                filePath = path
            } else {
                filePath = url.appendingPathComponent("breweriesTable").appendingPathExtension("db").path
            }
            let dataBase = try Connection(filePath)
            self.dataBase = dataBase
            self.createDB()
        } catch {
            self.dataBase = nil
            let nserror = error as NSError
            print ("Cannot connect to Database. Error is: \(nserror), \(nserror.userInfo)")
        }
    }
    
    private func createDB(){
        do {
            try dataBase?.run(breweriesTable.create(ifNotExists: true){ table in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(breweryType)
                table.column(addres1)
                table.column(addres2)
                table.column(addres3)
                table.column(city)
                table.column(stateProvince)
                table.column(postalCode)
                table.column(country)
                table.column(longtitude)
                table.column(latitude)
                table.column(phone)
                table.column(websiteUrl)
                table.column(state)
                table.column(street)
            })
        } catch {
            let nserror = error as NSError
            print ("Cannot create Database. Error is: \(nserror), \(nserror.userInfo)")
        }
    }
    
   private func populateDB(brewery: Brewery) {
        let insertBrewery = self.breweriesTable.insert(self.id <- brewery.id, self.name <- brewery.name, self.breweryType <- brewery.breweryType, self.addres1 <- brewery.addres1, self.addres2 <- brewery.addres2, self.addres3 <- brewery.addres3, self.city <- brewery.city, self.stateProvince <- brewery.stateProvince, self.postalCode <- brewery.postalCode, self.country <- brewery.country, self.longtitude <- brewery.longtitude, self.latitude <- brewery.latitude, self.phone <- brewery.phone, self.websiteUrl <- brewery.websiteUrl, self.state <- brewery.state, self.street <- brewery.street)
        
        do {
            try self.dataBase?.run(insertBrewery)
        } catch {
            print("Error inserting: \(error)")
        }
    }
    
    private func dataBaseURL(url: URL) -> String? {
        let dbPath = url.appendingPathComponent("breweriesTable.db").path
        if !fileManager.fileExists(atPath: dbPath) {
            return nil
        } else {
            return dbPath
        }
    }
    
    func retrieveBreweries() -> [Brewery] {
        var breweries: [Brewery] = []
        do {
            guard let fetchedTable = try self.dataBase?.prepare(self.breweriesTable) else {
                return breweries
            }
            _ = try fetchedTable.map { row in
                let brewery = Brewery(id: try row.get(id), name: try row.get(name), breweryType: try row.get(breweryType), addres1: try row.get(addres1), addres2: try row.get(addres2), addres3: try row.get(addres3), city: try row.get(city), stateProvince: try row.get(stateProvince), postalCode: try row.get(postalCode), country: try row.get(country), longtitude: try row.get(longtitude), latitude: try row.get(latitude), phone: try row.get(phone), websiteUrl: try row.get(websiteUrl), state: try row.get(state), street: try row.get(street))
                breweries.append(brewery)
            }
        } catch {
           print(error)
        }
        return breweries
    }
    
    func updateDB(with breweries: [Brewery]){
        guard let db = dataBase else {return}
        for brewery in breweries {
            let updatedBrewery = self.breweriesTable.filter(self.id == brewery.id)
            do {
                if try db.run(updatedBrewery.update(brewery)) > 0 {
                } else {
                    self.populateDB(brewery: brewery)
                }
            } catch {
                print("update failed: \(error)")
            }
        }
    }
}
