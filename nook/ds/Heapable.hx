package nook.ds;

interface Heapable<T> {
	var heapIndex: Int;
	function higherPriority( other: T ): Bool;
}
