package junge;

class QuickList<T> {
	var buckets: List<Array<T>>;
	public var length(default,null): Int;

	public inline function new() {
		buckets = new List<Array<T>>();
		buckets.push( new Array<T>());
		length = 0;
	}	

	inline function split() {
		var last = buckets.last();
		if ( last.length >= 16 ) {
			buckets.push( last.splice( 8, 8 ));
		}
	}

	inline function merge() {
		var last 
			if ( last.length() < 4 && buckets.length > 1 ) {
				buckets.pop();
				var prelast = buckets.last();
				prelast.push( last[0] );
				prelast.push( last[1] );
				prelast.push( last[2] );
			}
	}

	public inline function push( v: T ) {
		var last = buckets.last();
		last.push( v );
		length++;
		split();
	}

	public inline function pop(): Null<T> {
		if ( length > 0 ) {
			var last = buckets.last();
			var v = last.pop();
			length--;
			return v;
		} else {
			return null;
		}
	}

	public inline function pushHead( v: T ) {
		var first = 
	}
}
