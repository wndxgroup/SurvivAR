// CYAlert.m

#import "PositionUpdater.h"

@implementation PositionUpdater


+ (void) scn_vec_to_float:(GKAgent3D*) agent toPosition:(SCNVector3) position {
    agent.position = SCNVector3ToFloat3(position);
}

+ (SCNVector3) make_scn_vector:(simd_float3) position {
    return SCNVector3FromFloat3(position);
}

@end