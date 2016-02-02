package nook.ds;

enum Tree23<K,V> {
	Nil;
	Node2( x: Pair<K,V>, l: Tree23<K,V>, r: Tree23<K,V> );
	Node3( x: Pair<K,V>, y: Pair<K,V>, l: Tree23<K,V>, m: Tree23<K,V>, r: Tree23<K,V> );
}

class Tree23Utils<K,V> {
	static public function add<K,V>( tree: Tree23<K,V>, k: K, v: V ) return switch ( tree ) {
		case Nil: 
			Node2(new Pair(k,v),Nil,Nil);
		
		case Node2(x,Nil,Nil): 
			if ( k < x.a )
				Node3(new Pair(k,v),x,Nil,Nil,Nil);
			else if ( k > x.a )
				Node3(x,new Pair(k,v),Nil,Nil,Nil);
			else
				Node2(new Pair(k,v),Nil,Nil);
		
		case Node3(x,y,Nil,Nil,Nil): 
			if ( k < x.a ) 
				Node2(x,Node2(new Pair(k,v),Nil,Nil),Node2(y,Nil,Nil));
			else if ( k == x.a )
				Node3(new Pair(k,v),y,Nil,Nil,Nil);
			else if ( k < y.a )
				Node3(new Pair(k,v),Node2(x,Nil,Nil),Node2(y,Nil,Nil));
			else if ( k == y.a )
				Node3(x,new Pair(k,v),Nil,Nil,Nil);
			else
				Node2(y,Node2(x,Nil,Nil),Node2(new Pair(k,v),Nil,Nil));	

		}
	}

	static public function remove<K,V>( tree: Tree23<K,V>, k: K ) {
	
	}

	static public function get<K,V>( tree: Tree<K,V>, k: K ) {
			
	}

	static public function toTree23<V>( it: Iterable<V> ) {
		var tree: Tree23<Int,V> = Nil;
		for ( v in it ) {
			tree = tree.add( v );
		}
		return tree;
	}
}

