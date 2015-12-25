package nook.ds;

class Pair<F,S> {
	public var first: F;
	public var second: S;

	public inline function new( first: F, second: S ) {
		this.first = first;
		this.second = second;
	}
}
