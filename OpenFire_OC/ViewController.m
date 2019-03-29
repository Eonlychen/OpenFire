//
//  ViewController.m
//  OpenFire_OC
//
//  Created by guxiangyun on 2019/3/28.
//  Copyright © 2019 chenran. All rights reserved.
//

#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import "GameScene.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    GameScene *scene = [[GameScene alloc] initWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeFill;
    SKView *view = [SKView.alloc  initWithFrame:self.view.frame];
    
    [view presentScene:scene];
    view.ignoresSiblingOrder = true;
    
    view.showsFPS = true;
    view.showsNodeCount = true;
    self.view = view;
}


@end
