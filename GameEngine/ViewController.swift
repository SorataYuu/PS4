//
//  ViewController.swift
//  GameEngine
//
//  Created by Jeremy Jee on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import UIKit

/**
 ViewController that controls what is being displayed
 
 Variables:
 - gameArea: The IBOutlet for the UIView of the whole screen
 - bubbleCollectionView: The IBOutlet of the UICollectionView for the Grid of Bubbles
 - bubbleSize: Size of the Bubbles on Screen
 - controller: Reference to the Controller class
 - projectile: Reference to the Projectile displayed on screen
 */
class ViewController: UIViewController {

    @IBOutlet weak var gameArea: UIView!
    @IBOutlet weak var bubbleCollectionView: UICollectionView!
    
    var bubbleSize: CGFloat!
    var controller: Controller!
    var projectile = UIImageView()
    
    //Initial Method to run
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGameArea()
        
        controller = Controller(self)
    }
    
    //Set up the Game Area
    private func setUpGameArea() {
        bubbleCollectionView.delegate = self
        bubbleCollectionView.dataSource = self
        
        bubbleSize = gameArea.frame.width / CGFloat(Constants.evenRowBubbleCount)
        
        gameArea.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(self.gameAreaTapped)))
    }
    
    //Make Game Full Screen
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Obtain the Initialization Variables for the Physics Engine
    override func viewWillAppear(_ animated: Bool) {
        let bubblePositions = self.getBubblePositions()
        controller.setupPhysics(bubbleSize: bubbleSize,
                                bubblePositions: bubblePositions,
                                screenWidth: gameArea.frame.width,
                                screenHeight: gameArea.frame.height)
    }
    
    //Obtain the Positions of the Bubbles Slots on the Screen
    /// Returns:
    ///  - Dictionary<Int, [CGPoint]> of a Matrix of Positions for the Bubble Slots
    private func getBubblePositions() -> [Int: [CGPoint]] {
        var bubblePositions = [Int: [CGPoint]]()
        
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
    
    //Create a new Projectile on screen
    /// Parameters:
    ///  - bubble: Bubble to use as Projectile
    func createProjectile(projectile bubble: Bubble) {
        let bubbleImage = UIImage(named: bubble.imageName)
        projectile = UIImageView(image: bubbleImage)
        
        let posX = (gameArea.frame.width/2) - bubbleSize/2
        let posY = gameArea.frame.height - bubbleSize
        
        projectile.frame.origin = CGPoint(x: posX, y: posY)
        projectile.frame.size = CGSize(width: bubbleSize, height: bubbleSize)
        
        gameArea.addSubview(projectile)
        
        animateExpansion(node: projectile)
    }
    
    //Receive the User's Tap on screen
    func gameAreaTapped(sender: UITapGestureRecognizer) {
        enableInteraction(isEnabled: false)
        
        let tappedPoint = sender.location(in: gameArea)
        let path = controller.calculateProjectilePath(origin: projectile.center,
                                                      tapped: tappedPoint)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.controller.shootFinished(destination: path.2)
        })
        
        animateShoot(node: projectile, path: path.0, distance: path.1)
        
        CATransaction.commit()
    }
    
    //Animate the Shrinking of Bubbles
    /// Parameter:
    ///  - indexPaths: The Bubbles to shrink
    func shrinkBubbles(at indexPaths: [IndexPath]) {
        CATransaction.begin()
        
        for indexPath in indexPaths {
            if let bubble = bubbleCollectionView.cellForItem(at: indexPath) {
                CATransaction.setCompletionBlock({
                    self.controller.shrinkFinished(at: indexPath)
                    bubble.layer.removeAllAnimations()
                })
                
                animateShrink(node: bubble)
            }
        }
        CATransaction.commit()
    }
    
    //Drop the Unconnected Bubbles
    /// Parameter:
    ///  - indexPaths: The Bubbles to drop
    func dropUnconnected(at indexPaths: [IndexPath]) {
        CATransaction.begin()
        
        for indexPath in indexPaths {
            if let bubble = bubbleCollectionView.cellForItem(at: indexPath) {
                let originalPosition = bubble.center
                
                CATransaction.setCompletionBlock({
                    self.controller.dropFinished(at: indexPath)
                    bubble.center = originalPosition
                    bubble.layer.removeAllAnimations()
                })
                
                animateDrop(node: bubble)
            }
        }
        CATransaction.commit()
    }
    
    //Animate Shooting
    /// Parameters:
    ///  - node: The Object to Shoot
    ///  - path: The Path to shoot it along
    ///  - distance: The Distance that the path moves
    private func animateShoot(node: UIView, path: CGPath, distance: CGFloat) {
        let keyframeAnimation = CAKeyframeAnimation(keyPath: "position")
        keyframeAnimation.path = path
        keyframeAnimation.fillMode = kCAFillModeForwards
        keyframeAnimation.isRemovedOnCompletion = false
        keyframeAnimation.duration = Double(distance/Constants.speedPerPixel)
        keyframeAnimation.calculationMode = kCAAnimationCubicPaced
        
        //Named move
        node.layer.add(keyframeAnimation, forKey: "move")
        
        node.layer.position = path.currentPoint
    }
    
    //Animate Expansion
    /// Parameters:
    ///  - node: The Object to Expand
    private func animateExpansion(node: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.fromValue = CGFloat(0.001)
        animation.toValue = CGFloat(1)
        animation.duration = Double(0.5)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        //Named expand
        node.layer.add(animation, forKey: "expand")
    }
    
    //Animate Shrinking
    /// Parameters:
    ///  - node: The Object to Shrink
    private func animateShrink(node: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = CGFloat(0.001)
        animation.duration = Double(0.5)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        //Named shrink
        node.layer.add(animation, forKey: "shrink")
    }
    
    //Animate Drop
    /// Parameters:
    ///  - node: The Object to Drop
    private func animateDrop(node: UIView) {
        let animation = CABasicAnimation(keyPath: "position.y")
        
        let destinationY = view.frame.height + bubbleSize
        let durationRatio = destinationY - node.center.y
        
        animation.toValue = destinationY
        animation.duration = 0.002 * Double(durationRatio)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        node.layer.add(animation, forKey: "move")

    }
    
    //Control the ability to Interact
    /// Parameters:
    ///  - isEnabled: Should be Enabled or not
    func enableInteraction(isEnabled: Bool) {
        gameArea.isUserInteractionEnabled = isEnabled
    }
    
    //Update the Bubble's Color
    /// Parameters:
    ///  - indexPath: Bubble to be updated
    func updateBubbleColor(at indexPath: IndexPath) {
        if controller.getBubbleType(at: indexPath) == .empty {
            let bubbleCell = bubbleCollectionView.cellForItem(at: indexPath) as! BubbleCell
            bubbleCell.bubbleImageView.image = nil
        } else {
            if let imageName = controller.getBubbleImageName(at: indexPath) {
                let backgroundImage = UIImage(named: imageName)
                
                let bubbleCell = bubbleCollectionView.cellForItem(at: indexPath) as! BubbleCell
                bubbleCell.bubbleImageView.image = backgroundImage
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
// Code based of https://www.raywenderlich.com/136159/uicollectionview-tutorial-getting-started
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Determines the number of rows in the grid
    //In this case each row is a section in the Collection View
    //Number of Rows corresponds with the Number of Rows in the BubbleGrid
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return controller.getNoOfRows()
    }
    
    //Determines the number of item in each row
    //Number of Items in each row corresponds with the Number of Items
    //in the row of the BubbleGrid
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return controller.getNoOfItems(at: section)
    }
    
    //Handles the creation of a cell in the Collection View
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Create a BubbleCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier,
                                                      for: indexPath) as! BubbleCell
        
        //Assign the image of the bubble to the Image View within the BubbleCell
        if controller.getBubbleType(at: indexPath) != .empty {
            if let imageName = controller.getBubbleImageName(at: indexPath) {
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
        let widthPerItem = availableWidth / CGFloat(Constants.evenRowBubbleCount)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //Centers the Bubbles by placing offsets on the left and right
    //Bottom Offset is mathematically calculated using Hexagonal Packing
    //Code from: https://stackoverflow.com/questions/34267662/how-to-center-horizontally-uicollectionview-cells
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let viewWidth = bubbleCollectionView.frame.width
        let cellWidth = viewWidth / CGFloat(Constants.evenRowBubbleCount)
        
        //Small Offset for Cell Radius Padding, display glitch occurs on iPhone SE prbably due to rounding
        let cellRadius = CGFloat((cellWidth / 2 + Constants.cellRadiusOffset))
        let bottomInset = CGFloat(Constants.bottomOffsetForRows * cellRadius)
        
        //Offset by the radius of a bubble on Odd Rows
        if section % 2 == 0 {
            return UIEdgeInsets.init(top: 0, left: 0, bottom: bottomInset, right: 0)
        } else {
            return UIEdgeInsets.init(top: 0, left: cellRadius, bottom: bottomInset, right: cellRadius)
        }
    }
    
    //Sets the Minimum Line Spacing for Rows to be 0
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
