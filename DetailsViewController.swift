//
//  DetailsViewController.swift
//  MovieApp2
//
//  Created by Dat Hoang on 7/7/16.
//  Copyright © 2016 Dat Hoang. All rights reserved.
//

import UIKit
import AFNetworking
class DetailsViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    var posterUrlString: String = ""
    var overview: String = ""
    var movieTitle: String = ""
    var grayView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        posterImage.setImageWithURL(NSURL(string: posterUrlString)!)
        
        titleLabel.text = movieTitle
        titleLabel.sizeToFit()
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        //infoView.frame = CGRectMake(infoView.frame.origin.x, infoView.frame.origin.y, infoView.frame.size.width, titleLabel.frame.size.height + overviewLabel.frame.size.height)
        infoView.frame.size.height = titleLabel.frame.size.height + overviewLabel.frame.size.height + 100
        
        
        scrollView.contentSize = CGSize (width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.height )
        grayView = UIView(frame: CGRectMake(50, 620, scrollView.contentSize.width - 100, 150))
        
        grayView.backgroundColor = UIColor.grayColor()
        //scrollView.addSubview(grayView)
       // print("started")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func SwipedOnPicture(sender: AnyObject) {
             }
    @IBAction func tappedOnInfo(sender: AnyObject) {
        scrollView.scrollRectToVisible(grayView.frame, animated: true)
        print("tapped")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
