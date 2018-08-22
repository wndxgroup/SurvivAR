#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <ARKit/ARKit.h>
#import <GameplayKit/GameplayKit.h>

@interface PositionUpdater : NSObject

+ (void) scn_vec_to_float:(GKAgent3D*) agent toPosition:(SCNVector3) position;

@end