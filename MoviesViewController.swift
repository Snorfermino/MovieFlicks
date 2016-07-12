//
//  MoviesViewController.swift
//  MovieApp2
//
//  Created by Dat Hoang on 7/7/16.
//  Copyright © 2016 Dat Hoang. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
class MoviesViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var listviewBttn: UIButton!
    
    @IBOutlet weak var gridviewBttn: UIButton!
    @IBOutlet weak var gridView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    var movies = [NSDictionary]()
    var baseUrl = "http://image.tmdb.org/t/p/w342"
   
    
    var networkErrorRect:UIView!
    var networkErrorLabel:UILabel!
       override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(animated: Bool) {
        gridView.backgroundColor = UIColor.whiteColor()
        tableView.alpha = 1
        gridView.alpha = 0
        listviewBttn.backgroundColor = UIColor.whiteColor()
        gridView.backgroundColor = UIColor.grayColor()
        addNetworkError()
        
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status: AFNetworkReachabilityStatus) -> Void in
            switch status {
            case .NotReachable:
                print("Not reachable")
                self.networkErrorRect.hidden = false
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            case .ReachableViaWiFi, .ReachableViaWWAN:
                print("Reachable")
                self.networkErrorRect.hidden = true
                // Display HUD right before the request is made
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.addPullToRefresh()
                //Request data from API
                self.fetchMovieDataFromAPI()
                
            case .Unknown:
                print("Unknown")
            }
            
        }
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        

        

       
        
        
 
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as! MovieCell
        //cell.textLabel?.text = String(indexPath.row)
        cell.titleLabel.text = movies[indexPath.row]["title"] as! String
        cell.overviewLabel.text = movies[indexPath.row]["overview"] as! String
        cell.overviewLabel.sizeToFit()
        
        let posterUrlString = baseUrl + (movies[indexPath.row]["poster_path"] as! String)
        cell.posterImage.setImageWithURL(NSURL(string: posterUrlString)!)
        
        return cell
    }
    
    func fetchMovieDataFromAPI(){
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                     completionHandler: { (dataOrNil, response, error) in
                                                                        if let data = dataOrNil {
                                                                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                                                data, options:[]) as? NSDictionary {
                                                                                //print("response: \(responseDictionary)")
                                                                                self.movies = responseDictionary["results"] as! [NSDictionary]
                                                                                self.tableView.reloadData()
                                                                                self.gridView.reloadData()
                                                                                // Hide HUD once the network request comes back (must be done on main UI thread)
                                                                                MBProgressHUD.hideHUDForView(self.view, animated: true)
                                                                            }
                                                                        }
        })
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        

        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                      completionHandler: { (data, response, error) in
                                                                        
                                                                        // ... Use the new data to update the data source ...
                                                                        
                                                                        // Reload the tableView now that there is new data
                                                                        self.tableView.reloadData()
    
                                                                        // Hide HUD once the network request comes back (must be done on main UI thread)
                                                                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                                                                        // Tell the refreshControl to stop spinning
                                                                        refreshControl.endRefreshing()	
        });
        task.resume()
    }
    
    func addNetworkError(){
        networkErrorLabel = UILabel(frame: CGRectMake(0, 0, tableView.contentSize.width, 29))
        
        networkErrorLabel.textAlignment = NSTextAlignment.Center
        networkErrorLabel.text = "Network Connection Not Found"
        self.view.addSubview(networkErrorLabel)
        
        networkErrorRect = UIView(frame: CGRectMake(0, 105, tableView.contentSize.width, 30))
        
        networkErrorRect.backgroundColor = UIColor.redColor()
        networkErrorRect.addSubview(networkErrorLabel)
        self.view.addSubview(networkErrorRect)

    }

    func addPullToRefresh(){
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl,atIndex: 0)
        gridView.insertSubview(refreshControl,atIndex: 0)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
 
     */
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        let nextVC = segue.destinationViewController as! DetailsViewController
        var ip:NSIndexPath
        if(self.tableView.alpha != 1){
            let cell = sender as! UICollectionViewCell
             ip = gridView.indexPathForCell(cell)!
        } else {
             ip = tableView.indexPathForSelectedRow!
            
        }
        let title = movies[ip.row]["title"] as! String
        let overview = movies[ip.row]["overview"] as! String
        let urlString = baseUrl + (movies[ip.row]["poster_path"] as! String)
        nextVC.movieTitle = title
        nextVC.overview = overview
        nextVC.posterUrlString = urlString
     }
    
    @available(iOS 6.0, *)
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return movies.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieGridCell", forIndexPath: indexPath) as! CollectionViewCell
        
        // Configure the cell
        //cell.movieTitleLabel.text = movies[indexPath.row]["title"] as! String
        
        let posterUrlString = baseUrl + (movies[indexPath.row]["poster_path"] as! String)
        cell.thumbnail.setImageWithURL(NSURL(string: posterUrlString)!)
        
        return cell
    }

    @IBAction func GridViewPressed(sender: UIButton) {
        
        
        let propertyToCheck = sender.currentTitle!
        switch propertyToCheck {
        case "Grid View" :
            self.gridView.alpha = 1
            self.tableView.alpha = 0
            gridviewBttn.backgroundColor = UIColor.whiteColor()
            listviewBttn.backgroundColor = UIColor.grayColor()
        
        case "List View" :
            self.tableView.alpha = 1
            self.gridView.alpha = 0
            listviewBttn.backgroundColor = UIColor.whiteColor()
            gridviewBttn.backgroundColor = UIColor.grayColor()
        
        default: break
        }
        
    }

}


