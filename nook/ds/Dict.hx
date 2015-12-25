package nook.ds;

class Dict<K,V> {
	public var key(default,null): K;
	public var value(default,null): V;
	public var left(default,null): Dict<K,V>;
	public var right(default,null): Dict<K,V>;
	public var level(default,null): Int;

	public static function compare<K>( a: K, b: K ) {
		return Reflect.compare( a, b );
	}

	static inline function newNode<K,V>( key: K, value: V, left: Dict<K,V>, right: Dict<K,V>, level: Int ) {
		var self = new Dict<K,V>( key, value);
		self.left = left;
		self.right = right;
		self.level = level;
		return self;
	}
	
	public static macro function toMap<K,V>( bst: ExprOf<Dict<K,V>>) {
		return macro {
			foldl( $bst, new Map(), function( k, v, acc ) { acc[k] = v; return acc; } );
		}
	}

	public static function toList<K,V>( bst: Dict<K,V> ) {
		return foldl( bst, List.ListAdt.Nil, function( k, v, acc ) return List.cons( new Pair<K,V>(k,v), acc ));
	}

	public static function toDict<K,V>( m: Map<K,V>, ?bst: Dict<K,V> ) {
		for ( k in m.keys()) {
			bst = set( bst, k, m[k] );
		}
		return bst;
	}
	
	public inline function new( key: K, value: V ) {
		this.key = key;
		this.value = value;
		this.left = null;
		this.right = null;
		this.level = 1;
	}

	static inline function skew<K,V>( bst: Dict<K,V> ) {
		if ( bst != null ) {
			var lbst = bst.left;
			if ( lbst != null ) {
				var level = bst.level;
				var llevel = lbst.level;
				if ( level == llevel ) {
					var rbst = newNode( bst.key, bst.value, lbst.right, bst.right, level );
					bst = newNode( lbst.key, lbst.value, lbst.left, rbst, level );
				}
			}
		}
		return bst;
	}

	static inline function split<K,V>( bst: Dict<K,V> ) {
		if ( bst != null ) {
			var rbst = bst.right;
			if ( rbst != null ) {
				var rrbst = rbst.right;
				if ( rrbst != null ) {
					var level = bst.level;
					var rrlevel = rrbst.level;
					if ( level == rrlevel ) {
						var lbst = newNode( bst.key, bst.value, bst.left, rbst.left, level );
						bst = newNode( rbst.key, rbst.value, lbst, rrbst, level+1 );
					}
				}
			}
		}
		return bst;
	}

	static inline function rebalanceSet<K,V>( bst: Dict<K,V>) {
		return split( skew( bst ));
	}

	public static function set<K,V>( bst: Dict<K,V>, k: K, v: V ) {
		if ( bst == null ) {
			return new Dict<K,V>( k, v );
		} else {
			var cmp = compare( k, bst.key );
			if ( cmp == 0 ) {
				return newNode( bst.key, v, bst.left, bst.right, bst.level );
			} else if ( cmp < 0 ) {
				var rbst = set( bst.right, k, v );
				return rebalanceSet( newNode( bst.key, bst.value, bst.left, rbst, bst.level ));
			} else {
				var lbst = set( bst.left, k, v );
				return rebalanceSet( newNode( bst.key, bst.value, lbst, bst.right, bst.level ));
			}
		}
	}

	public static function get<K,V>( bst: Dict<K,V>, k: K ) {
		if ( bst == null ) {
			return null;
		} else {
			var cmp = compare( k, bst.key );
			if ( cmp == 0 ) {
				return bst.value;
			} else if ( cmp < 0 ) {
				return get( bst.left, k );
			} else {
				return get( bst.right, k );
			}
		}
	}

	public static inline function exists<K,V>( bst: Dict<K,V>, k: K ) {
		return get( bst, k ) != null;
	}

	static inline function predecessor<K,V>( bst: Dict<K,V> ) {
		bst = bst.left;
		while ( bst.right != null ) {
			bst = bst.right;
		}
		return bst;
	}

	static inline function successor<K,V>( bst: Dict<K,V> ) {
		bst = bst.right;
		while ( bst.left != null ) {
			bst = bst.left;
		}
		return bst;
	}

	static inline function min( a: Int, b: Int ) {
		return a < b ? a : b;
	}

	static inline function max( a: Int, b: Int ) {
		return a > b ? a : b;
	}

	static inline function decrease<K,V>( bst: Dict<K,V> ) {
		var shouldbe = min( bst.left.level, bst.right.level + 1 );
		if ( shouldbe < bst.level ) {
			return newNode( bst.key, bst.value, bst.left, bst.right, shouldbe );
		} else if ( shouldbe < bst.right.level ) {
			var rbst = newNode( bst.right.key, bst.right.value, bst.right.left, bst.right.right, shouldbe );
			return newNode( bst.key, bst.value, bst.left, rbst, bst.level );
		} else {
			return bst;
		}
	}	

	static inline function rebalanceRemove<K,V>( bst: Dict<K,V> ) {
		var bst1 = skew( decrease( bst ));
		var bst2 = newNode( bst1.key, bst1.value, bst1.left, skew( bst1.right ), bst1.level );
		var bst3 = if ( bst2 != null ) {
			split( bst2.right );
		} else {
			var r = bst2.right;
			var rbst = newNode( r.key, r.value, r.left, skew( r.right ), r.level );
			split( newNode( bst2.right.key, bst2.right.value, bst2.left, rbst, bst2.level ));
		}
		return newNode( bst3.key, bst3.value, bst3.left, split( bst3.right ), bst3.level );
	}

	public static function remove<K,V>( bst: Dict<K,V>, k: K ) {
		if ( bst != null ) {
			var cmp = compare( k, bst.key );
			if ( cmp == 0 ) {
				if ( bst.right == null && bst.left == null ) {
					return null;
				} else {
					if ( bst.left == null ) {
						var succ = successor( bst );
						var rbst = remove( bst.right, succ.key );
						return newNode( succ.key, succ.value, null, rbst, bst.level );
					} else {
						var pred = predecessor( bst );
						var lbst = remove( bst.left, pred.key );
						return newNode( pred.key, pred.value, lbst, bst.right, bst.level );
					}
				}
			} else if ( cmp < 0 ) {
				return rebalanceRemove( newNode( bst.key, bst.value, remove( bst.left, bst.key ), bst.right, bst.level ));
			} else {
				return rebalanceRemove( newNode( bst.key, bst.value, bst.left, remove( bst.right, bst.key ), bst.level ));
			}
		}
		return bst;
	}

	public static function map<K,V,T>( bst: Dict<K,V>, f: K->V->T ): Dict<K,T> {
		if ( bst != null ) {
			return newNode( bst.key, f( bst.key, bst.value ), map( bst.left, f ), map( bst.right, f ), bst.level );
		} else {
			return null;
		}
	}
	
	public static function length<K,V>( bst: Dict<K,V> ) {
		if ( bst == null ) {
			return 0;
		} else {
			return 1 + length( bst.left ) + length( bst.right );
		}
	}
	
	public static function height<K,V>( bst: Dict<K,V> ) {
		if ( bst == null ) {
			return 0;
		} else {
			return 1 + max( height( bst.left ), height( bst.right ));
		}
	}

	public static function each<K,V>( bst: Dict<K,V>, f: K->V->Void ) {
		if ( bst != null ) {
			each( bst.left, f );
			f( bst.key, bst.value );
			each( bst.right, f );
		}
	}

	public static function filter<K,V>( bst: Dict<K,V>, p: K->V->Bool ) {
		if ( bst != null ) {
			if ( p( bst.key, bst.value )) {
				return newNode( bst.key, bst.value, filter( bst.left, p ), filter( bst.right, p ), bst.level );
			} else {
				return filter( remove( bst, bst.key ), p );
			}
		} else {
			return null;
		}
	}

	public static function foldl<K,V,T>( bst: Dict<K,V>, acc: T, f: K->V->T->T ) {
		if ( bst != null ) {
			return foldl( bst.right, foldl( bst.left, f( bst.key, bst.value, acc ), f), f);
		} else {
			return acc;
		}
	}

	public static function foldr<K,V,T>( bst: Dict<K,V>, acc: T, f: K->V->T->T ) {
		if ( bst != null ) {
			return foldr( bst.left, foldr( bst.right, f( bst.key, bst.value, acc ), f), f );
		} else {
			return acc;
		}
	}

	public static function count<K,V>( bst: Dict<K,V>, p: K->V->Bool ) {
		if ( bst != null ) {
			return (p( bst.key, bst.value ) ? 1 : 0) + count( bst.left, p ) + count( bst.right, p );
		} else {
			return 0;
		}
	}

	public static function merge<K,V>( bst1: Dict<K,V>, bst2: Dict<K,V> ) {
		var bst = bst1;
		each( bst2, function( k, v ) bst = set( bst, k, v ));
		return bst;
	}
}