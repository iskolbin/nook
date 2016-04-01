package nook.ds;

import nook.ds.LinkedList.LinkedListNode;

@:access(nook.ds.LinkedList)
class QuickList<T> {
	var buckets: LinkedList<Array<T>>;
	public var length(default,null): Int;

	public inline function new() {
		buckets = new LinkedList<Array<T>>();
		length = 0;
	}	

	inline function splitBucket( bucket: LinkedListNode<Array<T>> ) {
		if ( bucket.item.length >= 16 ) {
			buckets.insertNode( bucket.item.splice( 8, 8 ), bucket, bucket.next );
		}
	}

	inline function mergeBucket( bucket: LinkedListNode<Array<T>> ) {
		if ( bucket.item.length < 4 ) {
			if ( bucket.prev != null ) {
				for ( i in 0...bucket.item.length ) {
					bucket.prev.item.push( bucket.item[i] );
				}
				buckets.removeNode( bucket );
				splitBucket( bucket.prev );
			} else if ( bucket.next != null ) {
				for ( i in 0...bucket.next.item.length ) {
					bucket.item.push( bucket.next.item[i] );			
				}
				buckets.removeNode( bucket.next );
				splitBucket( bucket );
			} else if ( bucket.item.length == 0 ) {
				buckets.removeNode( bucket );
			}
		}
	}

	public inline function pushTail( v: T ) {
		if ( length == 0 ) {
			buckets.pushTail( [v] );
		} else {	
			buckets.tail.item.push( v );
			splitBucket( buckets.tail );
		}
		length++;
	}

	public inline function popTail(): Null<T> {
		if ( length > 0 ) {
			var v = buckets.tail.item.pop();
			mergeBucket( buckets.tail );
			length--;
			return v;
		} else {
			return null;
		}
	}

	public inline function pushHead( v: T ) {
		if ( length == 0 ) {
			buckets.pushHead( [v] );
		} else {	
			buckets.head.item.unshift( v );
			splitBucket( buckets.head );
		}
		length++;
	}
	
	public inline function popHead(): Null<T> {
		if ( length > 0 ) {
			var v = buckets.head.item.shift();
			mergeBucket( buckets.head );
			length--;
			return v;
		} else {
			return null;
		}
	}
}
