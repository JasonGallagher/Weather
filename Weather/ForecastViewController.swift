////
////  ForecastViewController.swift
////  Weather
////
////  Created by Jenny Gallagher on 3/24/15.
////  Copyright (c) 2015 Jenny Gallagher. All rights reserved.
//

import UIKit


class ForecastViewController: UIViewController, LocationListViewControllerDelegate {
    
    
    let locationController = LocationController()
    var selectedLocation : Location? = nil
    
    var useCelsius : Bool = false
    var useCelsiusSelected : Bool = false
    
    let forecastView : ForecastView = {
        let colors = UIColor.yellowToPinkColor()
        let view = ForecastView(topColor: colors.topColor, bottomColor: colors.bottomColor)
        return view
        }()
    
    
    override func loadView() {
        view = forecastView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Pull to refresh weather data
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        
        
        self.forecastView.cityListViewButton.addTarget(self, action: "cityListViewButtonTouched:", forControlEvents: .TouchUpInside)
        
        self.locationController.retrieveLocations({location, success in
            if success {
                self.requestWeatherData(location!, useCelsius: self.useCelsius)
                self.selectedLocation = location!
            }
        })
        
    }
    
    
    func cityListViewButtonTouched(sender: UIButton!) {
        let locationListViewController = LocationListViewController()
        locationListViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: locationListViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    
    func didSelectLocationInLocationListViewController(controller: LocationListViewController, didSelectLocation location: Location, useCelsius : Bool) {
        requestWeatherData(location, useCelsius: useCelsius)
        selectedLocation = location
        useCelsiusSelected = useCelsius
    }
    
    
    func requestWeatherData(location : Location, useCelsius : Bool){
        self.locationController.requestWeatherDataForLocation(location, useCelsius: useCelsius, completion: { (success, weather) -> Void in
            if success {
                self.forecastView.tempLabel.text = "\(weather.temperature!)°"
                self.forecastView.iconImage.image = weather.condition!.icon()
                self.forecastView.summaryLabel.text = weather.summary
                self.forecastView.tempMinMaxLabel.text = "\(weather.temperatureMin!)°/ \(weather.temperatureMax!)°"
                
                if weather.currentState!.isEmpty {
                    self.forecastView.cityLabel.text = weather.currentCity
                }
                else{
                    self.forecastView.cityLabel.text = "\(weather.currentCity!), \(weather.currentState!)"
                }
                
            }
        })
    }
    
    // Pull to refresh weather data with 1.5 second delay
    func respondToSwipeGesture(sender : UIGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Ended{
            let location = selectedLocation
            self.useCelsius = useCelsiusSelected
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
            if location != nil{
                self.forecastView.activityIndicatorView.startAnimating()
                self.forecastView.tempLabel.text = nil
                self.forecastView.summaryLabel.text = nil
                self.forecastView.iconImage.image = nil
                self.forecastView.tempMinMaxLabel.text = nil
                
                self.requestWeatherData(location!, useCelsius: useCelsius)
                dispatch_after(dispatchTime, dispatch_get_main_queue(), { () -> Void in
                    self.forecastView.activityIndicatorView.stopAnimating()
                })
                
            }}
    }
    
}


