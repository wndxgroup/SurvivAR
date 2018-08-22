// CYAlert.m

#import "PositionUpdater.h"

@implementation PositionUpdater


+ (void) scn_vec_to_float:(GKAgent3D*) agent toPosition:(SCNVector3) position {
    agent.position = SCNVector3ToFloat3(position);
}

@end