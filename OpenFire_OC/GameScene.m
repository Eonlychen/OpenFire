//
//  GameScene.m
//  OpenFire_OC
//
//  Created by guxiangyun on 2019/3/28.
//  Copyright © 2019 chenran. All rights reserved.
//

#import "GameScene.h"
#import "Music.h"

@interface GameScene ()<SKPhysicsContactDelegate>
{
    NSTimeInterval duration;
    NSInteger   currentBullet;
    SKEmitterNode *emitter;/** 加载sks粒子配置文件 */
    SKSpriteNode *shipNode;
    SKSpriteNode *floor1;
    SKSpriteNode *floor2;
    SKSpriteNode *floor3;
    SKSpriteNode *floor_temp;
}
/** bullets */
@property (nonatomic, strong) NSMutableArray *bullets;
/** bulletSound */
@property (nonatomic, strong) NSMutableArray *bulletSound;
/** floors */
@property (nonatomic, strong) NSMutableArray *floors;

@end

@implementation GameScene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    self.size = UIScreen.mainScreen.bounds.size;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    [self setBackground];
    [self move];
    [self addPlane];
    [self openFire];
    [self shootBullet];
    [[Music shareInstance] playBGM];
    [self randomCreateBarrier];
}

#pragma mark -- private
// 添加飞机
- (void)addPlane {
    shipNode.position = CGPointMake(CGRectGetMidX(self.frame), 50);
    shipNode.anchorPoint= CGPointMake(0.5, 0.5);
    shipNode.zPosition = 1.0;
    [self addChild:shipNode];
}
// 添加背景
- (void)setBackground {
    [self.floors addObject:floor1];
    [self.floors addObject:floor2];
    [self.floors addObject:floor3];
    for (int i = 0; i< self.floors.count; i++) {
        SKSpriteNode *node = self.floors[i];
        node.position = CGPointMake(0, i*self.frame.size.height);
        node.anchorPoint= CGPointZero;
        node.size = self.frame.size;
    }
    [self addChild:floor1];
    [self addChild:floor2];
    [self addChild:floor3];
}
// 背景滚动
- (void)move {
    SKAction *moveAct = [SKAction waitForDuration:0.02];
    SKAction *generateAct = [SKAction runBlock:^{
        [self moveScene];
    }];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[moveAct,generateAct]]] withKey:@"move"];
}
// 滚动
- (void)moveScene {
    floor1.position = CGPointMake(0, floor1.position.y - 1);
    floor2.position = CGPointMake(0, floor2.position.y - 1);
    floor3.position = CGPointMake(0, floor3.position.y - 1);

    CGFloat height_pad = self.frame.size.height;
    
    if (floor1.position.y < -height_pad) {
        CGFloat height = floor3.position.y + height_pad;
        floor1.position = CGPointMake(0, height);
    }
    if (floor2.position.y < -height_pad) {
        CGFloat height = floor1.position.y + height_pad;
        floor2.position = CGPointMake(0, height);
    }
    if( floor3.position.y < -height_pad) {
        CGFloat height = floor2.position.y + height_pad;
        floor3.position = CGPointMake(0, height);
    }
    
}
// 发射子弹
- (void)shootBullet {
    //每隔1秒
   SKAction *waitAction =  [SKAction waitForDuration:0.7];
    //创建一个子弹
    SKAction *createBulletAction = [SKAction runBlock:^{
        SKSpriteNode *bullet = [[SKSpriteNode alloc] initWithImageNamed:@"bullet_clear"];
        bullet.position = self->shipNode.position;
        bullet.name = @"bullet";
        bullet.zPosition = 1.0;
        bullet.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, bullet.size.width, bullet.size.height)];
        bullet.physicsBody.categoryBitMask = 2;
        bullet.physicsBody.contactTestBitMask = 1;
        [self addChild:bullet];

        //发射子弹
        SKAction *fireAction = [SKAction moveTo:CGPointMake(self->shipNode.position.x, self.frame.size.height) duration:1.5];
        
        //触发射击音效
        SKAction *shootSound = [SKAction runBlock:^{
            [[Music shareInstance] bulletShootSound];
        }];
        
        SKAction *createAndSound = [SKAction group:@[fireAction,shootSound]];
        
        //子弹离开屏幕消失
        SKAction *endAction = [SKAction runBlock:^{
            [bullet removeFromParent];
        }];
        //动作组合
        SKAction *fireSequence = [SKAction sequence:@[createAndSound,endAction]];
        
        [bullet runAction:fireSequence];
    }];
    
    [self runAction: [SKAction repeatActionForever:[SKAction sequence:@[createBulletAction,waitAction]]]];
}

// 飞机火焰
- (void)openFire {
    NSString *burstPath = [NSBundle.mainBundle pathForResource:@"Spark" ofType:@"sks"];
//    emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    NSError *err = nil;
    emitter = [NSKeyedUnarchiver unarchivedObjectOfClass:[SKEmitterNode class] fromData:[NSData dataWithContentsOfFile:burstPath] error:&err];
    if (err) {
        NSLog(@"err::%@",err);
    }
    emitter.position = CGPointMake(CGRectGetMidX(self.frame), shipNode.position.y - 20);
    [self addChild:emitter];
}
// 爆炸效果
- (void)explode:(CGPoint)point {
    SKTextureAtlas *explodeAtlas = [SKTextureAtlas atlasNamed:@"exploded"];
    NSMutableArray *allTextureArray = [NSMutableArray arrayWithCapacity:16];
    for (int i = 0; i<explodeAtlas.textureNames.count; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d@2x.png",i+1];
        SKTexture *texture = [explodeAtlas textureNamed:textureName];
        [allTextureArray addObject:texture];
    }
    SKSpriteNode *bombNode = [SKSpriteNode spriteNodeWithTexture:allTextureArray[0]];
    bombNode.position = point;
    bombNode.name = @"bomb";
    bombNode.size = CGSizeMake(50, 50);
    bombNode.zPosition = 2.0;
    [self addChild:bombNode];

    SKAction *animationAction =[SKAction animateWithTextures:allTextureArray timePerFrame:0.05];
    SKAction *soundAction = [SKAction runBlock:^{
        [[Music shareInstance] bomb];
    }];
    [bombNode runAction:[SKAction group:@[animationAction,soundAction]] completion:^{
        [bombNode removeFromParent];
    }];
}
//:随机位置(x方向)落下障碍物
- (void)addBarriers {
    SKSpriteNode *barrier = [[SKSpriteNode alloc] initWithImageNamed:@"UFO"];
    barrier.name = @"barrier";
    CGFloat x_value = (CGFloat)arc4random_uniform(self.view.frame.size.width);
    CGFloat y_value = self.view.frame.size.height + 50;
    barrier.position = CGPointMake(x_value, y_value);
    barrier.zPosition = 1.0;
    barrier.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:barrier.frame.size];
    barrier.physicsBody.categoryBitMask = 1;
    barrier.physicsBody.affectedByGravity = false;
    barrier.physicsBody.contactTestBitMask = 2;
    [self addChild:barrier];
    [barrier runAction:[SKAction moveToY:0 duration:8.0] completion:^{
        [barrier removeAllActions];
        [barrier removeFromParent];
    }];

}
// 创建随机定时
- (void)randomCreateBarrier {
    SKAction *waitAct = [SKAction waitForDuration:2 withRange:1.0];
    SKAction *generateAct = [SKAction runBlock:^{
        [self addBarriers];
    }];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[generateAct,waitAct]]]];
    
}

// 默认配置
- (void)defaultSetting {
    duration = 0.5;
    currentBullet = 0;
    shipNode = [SKSpriteNode.alloc initWithImageNamed:@"ship_clear"];
    floor1 = [SKSpriteNode.alloc initWithImageNamed:@"universal_01"];
    floor2 = [SKSpriteNode.alloc initWithImageNamed:@"universal_02"];
    floor3 = [SKSpriteNode.alloc initWithImageNamed:@"universal_03"];
}


#pragma mark -- overwrite
//飞机操作---开始触摸
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = touches.anyObject;
    CGPoint locationPoint = [touch locationInNode:self];
    double newDuration = fabs(shipNode.position.x - locationPoint.x)/CGRectGetMidX(self.view.frame)*duration;
    CGPoint targetPoint = CGPointMake(locationPoint.x, shipNode.position.y);
    SKAction *shipMove = [SKAction moveTo:targetPoint duration:newDuration];
    SKAction *fireMove = [SKAction moveTo:CGPointMake(targetPoint.x, targetPoint.y-20) duration:newDuration];
    [shipNode runAction:shipMove];
    [emitter runAction:fireMove];
}
//飞机操作---结束触摸
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [shipNode removeAllActions];
    [emitter removeAllActions];
}

- (void)update:(NSTimeInterval)currentTime{
    
}


#pragma mark -- SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *bodyA;
    SKPhysicsBody *bodyB;
    if ([[contact bodyA] categoryBitMask] > [contact.bodyB categoryBitMask]) {
        bodyA = contact.bodyA;
        bodyB = contact.bodyB;
    }else {
        bodyA = contact.bodyB;
        bodyB = contact.bodyA;
    }
    if (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask ==1) {
        [self explode:bodyB.node.position];
        [bodyB.node removeFromParent];
        [bodyA.node removeFromParent];
    }
    
    
}
- (void)didEndContact:(SKPhysicsContact *)contact {
    
}



#pragma mark -- getter
- (NSMutableArray *)bullets {
    if (!_bullets) {
        _bullets = [NSMutableArray arrayWithCapacity:5];
    }
    return _bullets;
}
- (NSMutableArray *)bulletSound {
    if (!_bulletSound) {
        _bulletSound = [NSMutableArray arrayWithCapacity:5];
    }
    return _bulletSound;
}

- (NSMutableArray *)floors {
    if (!_floors) {
        _floors = [NSMutableArray arrayWithCapacity:3];
    }
    return _floors;
}


@end
