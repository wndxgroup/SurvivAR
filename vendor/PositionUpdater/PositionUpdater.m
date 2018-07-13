// CYAlert.m

#import "PositionUpdater.h"

@implementation PositionUpdater


+ (void) scn_vec_to_float:(GKAgent3D*) agent toPosition:(SCNVector3) position {
    agent.position = SCNVector3ToFloat3(position);
}


+ (void) show:(NSDictionary*) args {
    NSLog(@"%@", [args objectForKey: @"name"]);
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"This is Objective-C";
    alert.message = @"Mixing and matching!";
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    [alert release];
}

+ (SCNVector3) make_scn_vector:(simd_float3) position {
    return SCNVector3FromFloat3(position);
}

@end