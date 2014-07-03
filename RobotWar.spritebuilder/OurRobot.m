//
//  OurRobot.m
//  RobotWar
//
//  Created by Jacqueline Hudepohl on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "OurRobot.h"


typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateFireAtDetectedRobot,
    RobotStateFirstMove, // jh
    RobotStateCornerMove,
    RobotStateRandomFire
};

@implementation OurRobot {
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    NSString *_cornerID;
}


- (void)run {
    CGFloat maxX = 480.0;
    CGFloat maxY = 320.0;
    CGFloat midX = maxX / 2;
    CGFloat midY = maxY / 2;
    
    CGRect robotBox = [self robotBoundingBox];
    CGFloat robotX = CGRectGetMidX (robotBox);
    CGFloat robotY = CGRectGetMidY (robotBox);
    
    CGFloat dist;

    while (true) {
        if (_currentRobotState == RobotStateFireAtDetectedRobot) {
            
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateCornerMove;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else {
                    [self turnGunLeft:abs(angle)];
                }
                [self shoot];
            }
        }
        
        if (_currentRobotState == RobotStateDefault) {
            _currentRobotState = RobotStateFirstMove;
        }
        
        if (_currentRobotState == RobotStateFirstMove) {
            if ( maxX > maxY ) {
                dist = maxX;
            }
            else {
                dist = maxY;
            }

            if ( robotX < midX ) {
                if ( robotY < midY ) {
                    [self moveToXCoord:0.0 andYCoord:0.0 andDist:dist]; // lower left
                    _cornerID = @"LL";
                }
                else {
                    [self moveToXCoord:0.0 andYCoord:maxY andDist:dist]; // upper left
                    _cornerID = @"UL";
                }
            }
            else {
                if ( robotY < midY) {
                    [self moveToXCoord:maxX andYCoord:0.0 andDist:dist]; // lower right
                    _cornerID = @"LR";
                }
                else {
                    [self moveToXCoord:maxX andYCoord:maxY andDist:dist]; // upper right
                    _cornerID = @"UR";
                }
            }
            _currentRobotState = RobotStateFireAtDetectedRobot;
        }
        
        if (_currentRobotState == RobotStateCornerMove) {
            if ([_cornerID isEqualToString:@"LL"]) {
                [self moveToXCoord:maxX andYCoord:0.0 andDist:maxX];
                _cornerID = @"LR";
                [self moveGunDirectionToXCoord:0.0 andYCoord:maxY];
            }
            if ([_cornerID isEqualToString:@"LR"]) {
                [self moveToXCoord:maxX andYCoord:maxY andDist:maxY];
                _cornerID = @"UR";
                [self moveGunDirectionToXCoord:0.0 andYCoord:0.0];
            }
            if ([_cornerID isEqualToString:@"UR"]) {
                [self moveToXCoord:0.0 andYCoord:maxY andDist:maxX];
                _cornerID = @"UL";
                [self moveGunDirectionToXCoord:maxX andYCoord:0.0];
            }
            if ([_cornerID isEqualToString:@"UL"]) {
                [self moveToXCoord:0.0 andYCoord:0.0 andDist:maxY];
                _cornerID = @"LL";
                [self moveGunDirectionToXCoord:maxX andYCoord:maxY];
            }
            _currentRobotState = RobotStateRandomFire;
        }
        
        if (_currentRobotState == RobotStateRandomFire) {
            [self fireMultipleTimes];
        }
    }
}


- (void)moveToXCoord:(CGFloat)x andYCoord:(CGFloat)y andDist:(CGFloat)dist {
    CGPoint point = CGPointMake (x,y);
    CGFloat angle = [self angleBetweenHeadingDirectionAndWorldPosition:point];
    if (angle >= 0.0) {
        [self turnRobotRight:abs(angle)];
    } else {
        [self turnRobotLeft:abs(angle)];
    }
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
}


- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
    //[self shoot]; // jh
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFireAtDetectedRobot) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFireAtDetectedRobot;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {


}

@end
