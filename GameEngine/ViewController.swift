//
//  ViewController.swift
//  GameEngine
//
//  Created by Jeremy Jee on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var gameArea: UIView!
    @IBOutlet weak var bubbleCollectionView: UICollectionView!
    
    var bubbleSize: CGFloat!
    var projectile: UIImageView?
    var con: Controller!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        con = Controller(self)
        con.newProjectile()
        
        bubbleSize = gameArea.frame.width / CGFloat(evenRowBubbleCount)
        createProjectile()
        setUpGameArea()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let bubblePositions = self.calculateAllBubblePositions()
        con.setPhysicsVariables(bubbleSize: bubbleSize, bubblePositions: bubblePositions, screenWidth: gameArea.frame.width, screenHeight: gameArea.frame.height)
    }
    
    func calculateAllBubblePositions() -> Dictionary<Int, [CGPoint]> {
        var bubblePositions = Dictionary<Int, [CGPoint]>()
        
        for sectionNo in 0..<bubbleCollectionView.numberOfSections {
            bubblePositions[sectionNo] = [CGPoint]()
            
            for itemNo in 0..<bubbleCollectionView.numberOfItems(inSection: sectionNo) {
                let indexPath = IndexPath(item: itemNo, section: sectionNo)
                
                if let attributes = bubbleCollectionView.layoutAttributesForItem(at: indexPath) {
                    let bubblePos = attributes.center
                    
                    bubblePositions[sectionNo]!.append(bubblePos)
                }
            }
        }
    
        return bubblePositions
    }
    
    func setUpGameArea(){
        bubbleCollectionView.delegate = self
        bubbleCollectionView.dataSource = self
        
        gameArea.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(gameAreaTapped)))
    }
    
    func createProjectile(){
        let bubble = con.projectile
        
        let bubbleImage = UIImage(named: bubble.imageName)
        projectile = UIImageView(image: bubbleImage)
        
        let posX = (gameArea.frame.width/2) - bubbleSize/2
        let posY = gameArea.frame.height - bubbleSize
        
        projectile!.frame.origin = CGPoint(x: posX, y: posY)
        projectile!.frame.size = CGSize(width: bubbleSize, height: bubbleSize)
        
        gameArea.addSubview(projectile!)
    }
    
    func dropUnconnected(indexPaths: [IndexPath]) {
        CATransaction.begin()
        
        for indexPath in indexPaths {
            if let bubble = bubbleCollectionView.cellForItem(at: indexPath) {
                let originalPosition = bubble.center
                
                let animation = CABasicAnimation(keyPath: "position.y")
                CATransaction.setCompletionBlock({
                    self.con.dropCompletes(indexPath: indexPath)
                    bubble.center = originalPosition
                    bubble.layer.removeAllAnimations()
                })
                                
                let destinationY = view.frame.height + bubbleSize
                let durationRatio = destinationY - bubble.center.y
                
                animation.toValue = destinationY
                animation.duration = 0.002 * Double(durationRatio)
                animation.fillMode = kCAFillModeForwards
                animation.isRemovedOnCompletion = false
                
                bubble.layer.add(animation, forKey: "move")
            }
        }
        CATransaction.commit()
    }
    
    func gameAreaTapped(sender: UITapGestureRecognizer){
        enableInteraction(isEnabled: false)
        if let proj = projectile {
            let tappedPoint = sender.location(in: gameArea)
            let path = con.calculateBubblePath(origin: proj.center, tapped: tappedPoint)

            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.con.animationFinished(indexPath: path.2)
            })
            
            let keyframeAnimation = CAKeyframeAnimation(keyPath: "position")
            keyframeAnimation.path = path.0
            keyframeAnimation.fillMode = kCAFillModeForwards
            keyframeAnimation.isRemovedOnCompletion = false
            keyframeAnimation.duration = Double(path.1/speedPerPixel)
            keyframeAnimation.calculationMode = kCAAnimationCubicPaced
            
            proj.layer.add(keyframeAnimation, forKey: "move")
            
            proj.layer.position = path.0.currentPoint
            CATransaction.commit()
        }
    }
    
    func enableInteraction(isEnabled: Bool) {
        gameArea.isUserInteractionEnabled = isEnabled
    }
    
    func updateBubbleColor(indexPath: IndexPath) {
        if con.bubbleGrid.bubbleType(at: indexPath) == .empty {
            let bubbleCell = bubbleCollectionView.cellForItem(at: indexPath) as! BubbleCell
            bubbleCell.bubbleImageView.image = nil
        } else {
            if let imageName = con.bubbleGrid.bubbleImageName(at: indexPath) {
                let backgroundImage = UIImage(named: imageName)
                
                let bubbleCell = bubbleCollectionView.cellForItem(at: indexPath) as! BubbleCell
                bubbleCell.bubbleImageView.image = backgroundImage
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
// Code based of https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started
extension ViewController {
    
    //Determines the number of rows in the grid
    //In this case each row is a section in the Collection View
    //Number of Rows corresponds with the Number of Rows in the BubbleGrid
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return con.bubbleGrid.rows
    }
    
    //Determines the number of item in each row
    //Number of Items in each row corresponds with the Number of Items
    //in the row of the BubbleGrid
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return con.bubbleGrid.noOfItems(at: section)
    }
    
    //Handles the creation of a cell in the Collection View
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Create a BubbleCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! BubbleCell
        
        //Assign the image of the bubble to the Image View within the BubbleCell
        if con.bubbleGrid.bubbleType(at: indexPath) != .empty {
            if let imageName = con.bubbleGrid.bubbleImageName(at: indexPath) {
                let backgroundImage = UIImage(named: imageName)
                cell.bubbleImageView.image = backgroundImage
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
// Code based of https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started
extension ViewController : UICollectionViewDelegateFlowLayout {
    //Determines the Size of a BubbleCell
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Obtain the Width of the Screen
        //Since the Bubbles are tightly packed from edge to edge on the even row
        //The size of the Bubble would be based on squeezing all bubbles in the even row
        let availableWidth = bubbleCollectionView.frame.width
        let widthPerItem = availableWidth / CGFloat(evenRowBubbleCount)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //Centers the Bubbles by placing offsets on the left and right
    //Bottom Offset is mathematically calculated using Hexagonal Packing
    //Code from: https://stackoverflow.com/questions/34267662/how-to-center-horizontally-uicollectionview-cells
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let viewWidth = bubbleCollectionView.frame.width
        let cellWidth = viewWidth / CGFloat(evenRowBubbleCount)
        
        //Small Offset for Cell Radius Padding, display glitch occurs on iPhone SE prbably due to rounding
        let cellRadius = CGFloat((cellWidth/2 + cellRadiusOffset))
        let bottomInset = CGFloat(bottomOffsetForRows * cellRadius)
        
        //Offset by the radius of a bubble on Odd Rows
        if section % 2 == 0 {
            return UIEdgeInsetsMake(0, 0, bottomInset, 0)
        } else {
            return UIEdgeInsetsMake(0, cellRadius, bottomInset, cellRadius)
        }
    }
    
    //Sets the Minimum Line Spacing for Rows to be 0
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}



