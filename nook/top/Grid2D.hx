package nook.top;

class Grid2D implements Graph {
	public var moveCosts: Array<Float>;
	public var distance: Grid2DDistance;
	public var topology: Grid2DTopology;

	public inline function xOfNode( node: Int ) return node >> 16;
	public inline function yOfNode( node: Int ) return node & 0x0000ffff;
	public inline function nodeOfXy( x: Int, y: Int ) return (x << 16) + y;

	public function getNeighbors( node: Int ): Iterable<Int> {
		var x = xOfNode( node );
		var y = yOfNode( node );
		return switch ( topology ) {
			case Tex: [ nodeOfXy(x,(x+y)%2==0 ? y-1 : y+1), nodeOfXy(x-1,y), nodeOfXy(x+1,y) ];
			case Orth: [ nodeOfXy(x,y-1), nodeOfXy(x,y+1), nodeOfXy(x-1,y), nodeOfXy(x+1,y) ];
			case Hex: [ nodeOfXy(x,y-1), nodeOfXy(x,y+1), nodeOfXy(x-1,y), nodeOfXy(x+1,y), nodeOfXy(x+1,y+1), nodeOfXy(x-1,y+1) ];
			case Rect: [ nodeOfXy(x,y-1), nodeOfXy(x,y+1), nodeOfXy(x-1,y), nodeOfXy(x+1,y), nodeOfXy(x+1,y+1), nodeOfXy(x-1,y+1), nodeOfXy(x+1,y-1), nodeOfXy(x-1,y-1) ];
		}
	}
	
	public function getCost( start: Int, goal: Int ): Float {
		return moveCosts[goal];
	}
	
	public function getHeuristicCost( start: Int, goal: Int ): Float {
		var dx: Float = xOfNode( goal ) - xOfNode( start );
		var dy: Float = yOfNode( goal ) - yOfNode( start );
		return switch ( distance ) {
			case Dijkstra: 0;
			case Manhattan: Math.abs( dx ) + Math.abs( dy );
			case Euclidean: Math.sqrt( dx*dx + dy*dy );
			case Chebyshev: Math.max( Math.abs( dx ), Math.abs( dy ));
		}
	}
}	
