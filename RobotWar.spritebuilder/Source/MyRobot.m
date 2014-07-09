//
//  MyRobot.m
//  RobotWar
//
//  Created by Jacqueline Hudepohl on 7/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MyRobot.h"


typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateFireAtDetectedRobot,
    RobotStateMoveToCorner, // jh
    RobotStateRandomFire
};

@implementation MyRobot {
    RobotState _currentRobotState;
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    NSString *_corner;
    CGFloat _atCornerTimestamp;
}

CGFloat maxX = 480.0;
CGFloat maxY = 320.0;
CGFloat midX = 240.0;
CGFloat midY = 160.0;

- (void)run {
    
    
    CGRect robotBox = [self robotBoundingBox];
    CGFloat robotX = CGRectGetMidX (robotBox);
    CGFloat robotY = CGRectGetMidY (robotBox);
    while (true) {
        NSLog(_corner);
        if (_currentRobotState == RobotStateDefault) {
            NSLog(@"default");
        }
        else if (_currentRobotState == RobotStateMoveToCorner) {
            NSLog(@"movetocorner");
        }
        else if (_currentRobotState == RobotStateRandomFire) {
            NSLog(@"randomfire");
        }

        
        if (_currentRobotState == RobotStateDefault) {
            _currentRobotState = RobotStateMoveToCorner;
        }
        
        else if (_currentRobotState == RobotStateMoveToCorner) {
            NSLog(@"movetocorner");
            if ( robotX < midX ) {
                if ( robotY < midY ) {
                    _corner = @"LL";
                    [self moveToXCoord:0.0 andYCoord:0.0]; // lower left
                }
                else {
                    _corner = @"UL";
                    [self moveToXCoord:0.0 andYCoord:maxY]; // upper left
                }
            }
            else {
                if ( robotY < midY) {
                    _corner = @"LR";
                    [self moveToXCoord:maxX andYCoord:0.0]; // lower right
                }
                else {
                    _corner = @"UR";
                    [self moveToXCoord:maxX andYCoord:maxY]; // upper right
                }
            }
            _currentRobotState = RobotStateRandomFire;
        }
        
        
        else if (_currentRobotState == RobotStateRandomFire) {
            if ([_corner isEqualToString:@"LL"]) {
                [self moveGunDirectionToXCoord:0.0 andYCoord:maxY];
            }
            else if ([_corner isEqualToString:@"UL"]) {
                [self moveGunDirectionToXCoord:maxX andYCoord:maxY];
            }
            else if ([_corner isEqualToString:@"LR"]) {
                [self moveGunDirectionToXCoord:0.0 andYCoord:0.0];
            }
            else if ([_corner isEqualToString:@"UR"]) {
                [self moveGunDirectionToXCoord:maxX andYCoord:0.0];
            }
            [self fireMultipleTimes];
            CGFloat x = self.currentTimestamp;
            if (self.currentTimestamp - _atCornerTimestamp > 10.f) {
                NSLog(@"%f, %f" , x, _atCornerTimestamp);
                [self moveToNextCorner];
                _atCornerTimestamp = self.currentTimestamp;
            }
        }
    }
}

- (void) moveToNextCorner {
    if ([_corner isEqualToString:@"LL"]) {
        _corner = @"LR";
        [self moveToXCoord:maxX andYCoord:0.0];
    }
    else if ([_corner isEqualToString:@"LR"]) {
        _corner = @"UR";
        [self moveToXCoord:maxX andYCoord:maxY];
    }
    else if ([_corner isEqualToString:@"UR"]) {
        _corner = @"UL";
        [self moveToXCoord:0.0 andYCoord:maxY];
    }
    else if ([_corner isEqualToString:@"UL"]) {
        _corner = @"LL";
        [self moveToXCoord:0.0 andYCoord:0.0];
    }
    _currentRobotState = RobotStateRandomFire;
}

- (void)moveToXCoord:(CGFloat)x andYCoord:(CGFloat)y {
    CGPoint point = CGPointMake (x,y);
    CGFloat angle = [self angleBetweenHeadingDirectionAndWorldPosition:point];
    if (angle >= 0.0) {
        [self turnRobotRight:abs(angle)];
    } else {
        [self turnRobotLeft:abs(angle)];
    }
    
    CGRect robotBox = [self robotBoundingBox];
    CGFloat robotX = CGRectGetMidX (robotBox);
    CGFloat robotY = CGRectGetMidY (robotBox);
    CGFloat deltaX = abs(robotX - x);
    CGFloat deltaY = abs(robotY - y);
    CGFloat dist = sqrtf( pow(deltaX, 2) + pow(deltaY, 2));
    [self moveAhead:dist];
}

- (void) moveGunDirectionToXCoord:(CGFloat)x andYCoord:(CGFloat)y {
    CGPoint point = CGPointMake(x,y);
    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:point];
    if (angle >= 0) {
        [self turnGunRight:abs(angle)];
    }
    else {
        [self turnGunLeft:abs(angle)];
    }
}

-(void) fireMultipleTimes {
    NSInteger angle = 0;
    while (angle < 90) {
        [self shoot];
        angle += 10;
        [self turnGunRight:10];
    }
    angle = 0;
    while (angle < 90) {
        [self shoot];
        angle += 10;
        [self turnGunLeft:10];
    }
    
}



- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
    //[self shoot]; // jh
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    /* if (_currentRobotState != RobotStateFireAtDetectedRobot) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFireAtDetectedRobot; */
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    if (_currentRobotState != RobotStateRandomFire) {
        [self cancelActiveAction];
    }
    _currentRobotState = RobotStateRandomFire;
}

- (void) gotHit {
    [self moveToNextCorner];
}

@end
