//
//  LocationSearchTable.swift
//  Route360
//
//  Created by Glen Liu and Joshua Halberstadt on 11/28/21.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    // takes api entry and parses it into address form so search can show address
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between house number and street name
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space in state name if needed
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

extension LocationSearchTable : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }

        // place search query using MapKit API
        let searchRequest = MKLocalSearch.Request()
        // filter search by text in search bar
        searchRequest.naturalLanguageQuery = searchBarText
        // search for locations within current region
        searchRequest.region = mapView.region
        
        // start searching
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
                // add found entries to matchingItems variable
                self.matchingItems = response.mapItems
                // update table with latest text
                self.tableView.reloadData()
        }
    }
}

extension LocationSearchTable {
    
    // finds the number of rows to show
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    // find the text to put into each table entry
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        // find name of placemark from matchingItems array
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        // add address to the table by calling the parseAddress function
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        return cell
    }
    
}

extension LocationSearchTable {
    // handles what to do when an item in the search results is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        // calls dropPinZoomIn function from the original viewController
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        // dismiss the tableview (displays the mapView below)
        dismiss(animated: true, completion: nil)
    }
}
