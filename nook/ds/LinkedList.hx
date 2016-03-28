package junge;

private class LinkedListNode<T> {	
	public var item: T;
	public var prev: LinkedListNode<T>;
	public var next: LinkedListNode<T>;

	public inline function new( item: T, prev: LinkedListNode<T>, next: LinkedListNode<T> ) {
		this.item = item;
		this.prev = prev;
		this.next = next;
	}
}

private class LinkedListForwardIterator<T> {
	var head: LinkedListNode<T>;

	public inline function new( head: LinkedListNode<T> ) this.head = head;
	public inline function hasNext() return head != null;
	public inline function next(): T {
		var val = head.item;
		head = head.next;
		return val;
	}
}

private class LinkedListReverseIterator<T> {
	var tail: LinkedListNode<T>;

	public inline function new( tail: LinkedListNode<T> ) this.tail = tail;
	public inline function hasNext() return tail != null;
	public inline function next(): T {
		var val = tail.item;
		tail = tail.prev;
		return val;
	}
}

class LinkedList<T> {
	public var length(default,null): Int;
	public var head: LinkedListNode<T> = null;
	public var tail: LinkedListNode<T> = null;

	public function new( ?src: Iterable<T> = null ) {
		head = null;
		tail = null;
		length = 0;
		if ( src != null ) {
			for ( item in src ) {
				push( item );
			}
		}
	}

	public inline function pushTail( item: T ) {
		insertNode( item, tail, null );
	}

	public inline function popTail(): Null<T> {
		return length == 0 ? null : removeNode( tail );
	}

	public inline function pushHead( item: T ) {
		insertNode( item, null, head );
	}

	public inline function popHead(): Null<T> {
		return length > 0 ? removeNode( head ) : null;
	}

	public inline function peekHead(): Null<T> {
		return length == 0 ? null : head.item;
	}

	public inline function peekTail(): Null<T> {
		return length == 0 ? null : tail.item;
	}

	public function insert( pos: Int, x: T ) {
		var newpos = pos >= 0 ? pos : length + pos;
		if ( newpos <= 0 ) {
			pushHead( x );
		} else if ( newpos >= length ) {
			pushTail( x );
		} else if ( newpos <= Std.int( length/2 )) {
			var node = head;
			for ( i in 0...newpos ) node = node.next;	
			insertNode( x, node.prev, node.next );
		}	else {
			var node = tail;
			for ( i in 0...(length-newpos)) node = node.prev;
			insertNode( x, node.prev, node.next );
		}
	}

	public function sort( f: T->T->Int ) {
		// TODO implement merge sort
		var array = toArray();
		array.sort( f );
		clear();
		for ( v in array ) push( v );
	}

	function insertNode( item: T, prev: LinkedListNode<T>, next: LinkedListNode<T> ) {
		var node = new LinkedListNode<T>( item, prev, next );
		if ( length == 0 ) {
			length = 1;
			head = tail = node;
		} else if ( length == 1 ) {
			length = 2;
			if ( prev == null ) {
				head = node;
				tail.prev = node;
			} else {
				tail = node;
				head.next = node;	
			}
		} else {
			length++;
			if ( prev != null ) {
				prev.next = node;
			} else {
				head = node;	
			}
			if ( next != null ) {
				next.prev = node;
			} else {
				tail = node;
			}	
		}
	}

	public inline function copy(): LinkedList<T> {
		var result = new LinkedList<T>();
		var node = head;
		while ( node != null ) {
			result.push( node.item );
			node = node.next;
		}
		return result;
	}

	public function toString(): String {
		return "{" + join(", ") + "}";
	}

	public function join( sep: String ): String {
		var buffer = new StringBuf();
		var node = head;
		if ( !isEmpty()) {
			while ( node != tail ) {
				buffer.add( Std.string( node.item ));
				buffer.add( sep );
				node = node.next;			
			}
			buffer.add( Std.string( tail.item ));
		}
		return buffer.toString();
	}

	function removeNode( node: LinkedListNode<T> ): T {
		if ( length == 1 ) {
			length = 0;
			head = tail = null;
		} else if ( length == 2 ) {
			length = 1;
			if ( node == head ) {
				head = tail;
			} else {
				tail = head;
			}
			tail.next = tail.prev = null;
		} else {
			length--;
			if ( node.prev != null ) {
				node.prev.next = node.next;
			} else {
				head = node.next;
			}
			if ( node.next != null ) {
				node.next.prev = node.prev;
			} else {
				tail = node.prev;
			}
		}
		return node.item;
	}

	public function removeFirst( v: T ): Bool {	
		var node = head;
		while ( node != null ) {
			if ( node.item == v ) {	
				removeNode( node );
				return true;
			}
			node = node.next;
		}
		return false;
	}

	public function removeLast( v: T ): Bool {	
		var node = tail;
		while ( node != null ) {
			if ( node.item == v ) {	
				removeNode( node );
				return true;
			}
			node = node.prev;
		}
		return false;
	}

	public function removeAt( pos: Int ): Bool {
		var newpos = pos >= 0 ? pos : length + pos;
		if ( newpos < 0 ) {
			return false;
		} else if ( newpos >= length ) {
			return false;
		} else if ( newpos <= Std.int( length/2 )) {
			var node = head;
			for ( i in 0...newpos ) node = node.next;	
			removeNode( node );
			return true;
		}	else {
			var node = tail;
			for ( i in 0...(length-newpos)) node = node.prev;
			removeNode( node );
			return true;
		}
	}

	public function firstIndexOf( v: T ): Int {	
		var index = 0;
		var node = head;
		while ( node != null ) {
			if ( node.item == v ) {	
				return index;
			}
			index++;
			node = node.next;
		}
		return -1;
	}

	public function lastIndexOf( v: T ): Int {
		var index = 0;
		var node = tail;
		while ( node != null ) {
			if ( node.item == v ) {	
				return index;
			}
			index++;
			node = node.prev;
		}
		return -1;
	}

	public inline function exists( v: T ): Bool {
		return firstIndexOf( v ) == -1;
	}

	public inline function isEmpty() {
		return length == 0;
	}

	public inline function clear() {
		head = tail = null;
		length = 0;
	}

	public inline function iterator() {
		return new LinkedListForwardIterator<T>( head );
	}

	public inline function reverseIterator() {
		return new LinkedListReverseIterator<T>( tail );
	}

	public function merge( other: LinkedList<T> ) {
		if ( other != this ) {
			this.tail.next = other.head;
			other.head.prev = this.tail;
			this.tail = other.tail;
			
			other.head = null;
			other.tail = null;
			other.length = 0;
		}
	}

	public function reverse() {
		if ( length > 1 ) {
			var node = head;
			while ( node != null ) {
				var next = node.next;
				node.next = node.prev;
				node.prev = next;
				node = next;
			}
		}
		var newTail = head;
		head = tail;
		tail = newTail;
	}

	public function slice( pos: Int, ?end: Int ): LinkedList<T> {
		var result = new LinkedList<T>();
		var newpos = pos >= 0 ? pos : length + pos;
		var newend = end != null ? ( end >= 0 ? end : length + end ) : length;
		
		if ( newpos <= 0 ) {
			newpos = 0;
		} else if ( newpos >= length ) {
			return result;	
		} 

		if ( newend <= 0 ) {
			return result;
		} else if ( newend >= length ) {
			newend = length;
		} 
	
		if ( newpos <= length - 1 - newend ) {
			var node = head;
			for ( i in 0...newpos ) node = node.next;	
			for ( i in newpos...newend ) {
				result.pushTail( node.item );
				node = node.next;
			}
		} else {
			var node = tail;
			for ( i in newend...length ) node = node.prev;	
			for ( i in newpos...newend ) {
				result.pushHead( node.item );
				node = node.prev;
			}
		}

		return result;
	}

	public function splice( pos: Int, ?end: Int ): LinkedList<T> {
		var result = new LinkedList<T>();
		var newpos = pos >= 0 ? pos : length + pos;
		var newend = end != null ? ( end >= 0 ? end : length + end ) : length;
		
		if ( newpos <= 0 ) {
			newpos = 0;
		} else if ( newpos >= length ) {
			return result;	
		} 

		if ( newend <= 0 ) {
			return result;
		} else if ( newend >= length ) {
			newend = length;
		} 
	
		if ( newpos <= length - 1 - newend ) {
			var node = head;
			for ( i in 0...newpos ) node = node.next;	
			for ( i in newpos...newend ) {
				var next = node.next;
				result.pushTail( removeNode( node ));
				node = next;
			}
		} else {
			var node = tail;
			for ( i in newend...length ) node = node.prev;	
			for ( i in newpos...newend ) {
				var prev = node.prev;
				result.pushHead( removeNode( node ));
				node = prev;
			}
		}

		return result;
	}

	public function toArray() {
		var array = new Array<T>();
		var node = head;
		while ( node != null ) {
			array.push( node.item );
			node = node.next;
		}
		return array;
	}

	// Functional
	public function filter( p: T->Bool ): LinkedList<T> {
		var result = new LinkedList<T>();
		var node = head;
		while ( node != null ) {
			if ( p( node.item )) {
				result.push( node.item );
			}
			node = node.next;
		}
		return result;
	}

	public function map<X>( f: T->X ): LinkedList<X> {
		var result = new LinkedList<X>();
		var node = head;
		while ( node != null ) {
			result.push( f( node.item ));
			node = node.next;
		}
		return result;
	}

	public function foldl<X>( f: T->X->X, acc: X ): X {	
		var node = head;
		while ( node != null ) {
			acc = f( node.item, acc );
			node = node.next;
		}
		return acc;
	}

	public function foldr<X>( f: T->X->X, acc: X ): X {	
		var node = tail;
		while ( tail != null ) {
			acc = f( node.item, acc );
			node = node.prev;
		}
		return acc;
	}

	public function all( p: T-> Bool ): Bool {
		var node = head;
		while ( node != null ) {
			if ( !p( node.item )) {
				return false;
			}
			node = node.next;
		}
		return true;
	}

	public function any( p: T-> Bool ): Bool {
		var node = head;
		while ( node != null ) {
			if ( p( node.item )) {
				return true;
			}
			node = node.next;
		}
		return false;
	}

	public function unique(): LinkedList<T> {
		var result = new LinkedList<T>();
		if ( length > 0 ) {
			var node = tail;
			result.push( node.item );
			node = node.prev;
			while ( node != null ) {
				if ( result.exists( node.item )) {
					result.push( node.item );
				}
				node = node.prev;
			}
		}
		return result;
	}

	public inline function concat( src: Iterable<T> ) {
		var result = copy();
		for ( item in src ) {
			result.push( item );
		}
		return result;
	}

	// Aliases
	public inline function indexOf( v: T ) return firstIndexOf( v );
	public inline function remove( v: T ) removeFirst( v );
	public inline function push( v: T ) pushTail( v );
	public inline function pop(): Null<T> return popTail();
	public inline function enqueue( v: T ) pushTail( v );
	public inline function dequeue(): Null<T> return  popHead();
	public inline function unshift( v: T ) pushHead( v );
	public inline function shift(): Null<T> return popHead();
	public inline function add( v: T ) pushHead( v );
	public inline function first(): Null<T> return peekHead();
	public inline function last(): Null<T> return peekTail();
}
