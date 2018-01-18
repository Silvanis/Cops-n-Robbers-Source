#import "AStarNode.h"

@implementation AStarNode

@synthesize position, neighbors, active, costMultiplier;

-(id) init {
    if( (self=[super init]) ) {
		active = YES;
		neighbors = [[NSMutableArray alloc] init];
		costMultiplier = 1.0f;
    }
    return self;
}

/* Cost to node heuristic */
-(float) costToNode:(AStarNode*)node {
    CGFloat xDifference = self.position.x - node.position.x;
    CGFloat yDifference = self.position.y - node.position.y;
	float cost = ((abs(xDifference)) + (abs(yDifference))) * node.costMultiplier;
	return cost;
}

/* Helper method: Is a node in a given list? */
+(bool) isNode:(AStarNode*)a inList:(NSArray*)list {
	for(int i=0; i<list.count; i++){
		AStarNode *b = [list objectAtIndex:i];
		if(a.position.x == b.position.x && a.position.y == b.position.y){
			return YES;
		}
	}
	return NO;
}

@end