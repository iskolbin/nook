package nook.top;

interface Graph {
	public function getNeighbors( node: Int ): Iterable<Int>;
	public function getCost( start: Int, goal: Int ): Float;
	public function getHeuristicCost( start: Int, goal: Int ): Float;
}

