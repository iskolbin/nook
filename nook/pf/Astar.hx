package nook.pf;

import nook.ds.BinaryHeap;
import nook.ds.Heapable;
import nook.top.Graph;

private class GraphMove implements Heapable<GraphMove> {
	public var node(default,null): Int;
	public var cost(default,null): Float;
	public var heapIndex: Int;
	public inline function higherPriority( other: GraphMove ) {
		return cost > other.cost;
	}
	public inline function new( node: Int, cost: Float ) {
		this.node = node;
		this.cost = cost;
	}
}

class Astar {
	public static function findPath( graph: Graph, start: Int, goal: Int ): Array<Int> {
		var open = new BinaryHeap<GraphMove>( [new GraphMove( start, 0.0 )] );
		var cameFrom = new Map<Int,Int>();
		var costSoFar: Map<Int,Float> = [start => 0.0];
		while ( open.length > 0 ) {
			var current = open.dequeue().node;

			if ( current == goal ) {
				var result = new Array<Int>();
				while ( cameFrom.exists( current )) {
					result.push( current );
					current = cameFrom[current];
				}
				result.push( current );
				result.reverse();
				return result;
			}

			for ( next in graph.getNeighbors( current )) {
				var newCost = costSoFar[current] + graph.getCost( current, next );
				if ( !costSoFar.exists( next ) || newCost < costSoFar[next] ) {
					costSoFar[next] = newCost;
					open.enqueue( new GraphMove( next, graph.getHeuristicCost( goal, next )));
					cameFrom[next] = current;
				}	
			}
		}
		return null;
	}
}
