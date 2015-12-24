package nook.collections;

class AATree<K,V> {
	public var key(default,null): K;
	public var value(default,null): V;
	public var left(default,null): AATree<K,V>;
	public var right(default,null): AATree<K,V>;
	public var level(default,null): Int;

	static public function compare<K>( a: K, b: K ) {
		return Reflect.compare( a, b );
	}

	public inline function set( k: K, v: V ) return recSet( this, k, v );
	public inline function get( k: K ) return recGet( this, k );		
	public inline function remove( k: K ) return recRemove( this, k );
	public inline function map<T>( f: K->V->T ) return recMap( this, f );
	public inline function filter( p: K->V->Bool ) return recFilter( this, p );
	public inline function foldl<T>( f: K->V->T->T, acc: T ) return recFoldl( this, f, acc );
	public inline function foldr<T>( f: K->V->T->T, acc: T ) return recFoldr( this, f, acc );
	public inline function each( f: K->V->Void ) recEach( this, f );
	public inline function length() return recLength( this );
	public inline function height() return recHeight( this );
	public inline function count( p: K->V->Bool ) return recCount( this, p );
	
	static inline function newNode<K,V>( key: K, value: V, left: AATree<K,V>, right: AATree<K,V>, level: Int ) {
		var self = new AATree<K,V>( key, value);
		self.left = left;
		self.right = right;
		self.level = level;
		return self;
	}

	public static function fromMap<K1,V1>( m: Map<K1,V1>, ?out: AATree<K1,V1> ) {
		for ( k in m.keys()) {
			out = recSet( out, k, m[k] );
		}
		return out;
	}
	
	public inline function new( key: K, value: V ) {
		this.key = key;
		this.value = value;
		this.left = null;
		this.right = null;
		this.level = 1;
	}

	static inline function skew<K,V>( bst: AATree<K,V> ) {
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

	static inline function split<K,V>( bst: AATree<K,V> ) {
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

	static inline function rebalanceSet<K,V>( bst: AATree<K,V>) {
		return split( skew( bst ));
	}

	static function recSet<K,V>( bst: AATree<K,V>, k: K, v: V ) {
		if ( bst == null ) {
			return new AATree<K,V>( k, v );
		} else {
			var cmp = compare( k, bst.key );
			if ( cmp == 0 ) {
				return newNode( bst.key, v, bst.left, bst.right, bst.level );
			} else if ( cmp < 0 ) {
				var rbst = recSet( bst.right, k, v );
				return rebalanceSet( newNode( bst.key, bst.value, bst.left, rbst, bst.level ));
			} else {
				var lbst = recSet( bst.left, k, v );
				return rebalanceSet( newNode( bst.key, bst.value, lbst, bst.right, bst.level ));
			}
		}
	}

	static function recGet<K,V>( bst: AATree<K,V>, k: K ) {
		if ( bst == null ) {
			return null;
		} else {
			var cmp = compare( k, bst.key );
			if ( cmp == 0 ) {
				return bst.value;
			} else if ( cmp < 0 ) {
				return recGet( bst.left, k );
			} else {
				return recGet( bst.right, k );
			}
		}
	}

	static inline function predecessor<K,V>( bst: AATree<K,V> ) {
		bst = bst.left;
		while ( bst.right != null ) {
			bst = bst.right;
		}
		return bst;
	}

	static inline function successor<K,V>( bst: AATree<K,V> ) {
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

	static inline function decrease<K,V>( bst: AATree<K,V> ) {
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

	static inline function rebalanceRemove<K,V>( bst: AATree<K,V> ) {
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

	static function recRemove<K,V>( bst: AATree<K,V>, k: K ) {
		if ( bst != null ) {
			var cmp = compare( k, bst.key );
			if ( cmp == 0 ) {
				if ( bst.right == null && bst.left == null ) {
					return null;
				} else {
					if ( bst.left == null ) {
						var succ = successor( bst );
						var rbst = recRemove( bst.right, succ.key );
						return newNode( succ.key, succ.value, null, rbst, bst.level );
					} else {
						var pred = predecessor( bst );
						var lbst = recRemove( bst.left, pred.key );
						return newNode( pred.key, pred.value, lbst, bst.right, bst.level );
					}
				}
			} else if ( cmp < 0 ) {
				return rebalanceRemove( newNode( bst.key, bst.value, recRemove( bst.left, bst.key ), bst.right, bst.level ));
			} else {
				return rebalanceRemove( newNode( bst.key, bst.value, bst.left, recRemove( bst.right, bst.key ), bst.level ));
			}
		}
		return bst;
	}

	static function recMap<K,V,T>( bst: AATree<K,V>, f: K->V->T ): AATree<K,T> {
		if ( bst != null ) {
			return newNode( bst.key, f( bst.key, bst.value ), recMap( bst.left, f ), recMap( bst.right, f ), bst.level );
		} else {
			return null;
		}
	}
	
	static function recLength<K,V>( bst: AATree<K,V> ) {
		if ( bst == null ) {
			return 0;
		} else {
			return 1 + recLength( bst.left ) + recLength( bst.right );
		}
	}
	
	static function recHeight<K,V>( bst: AATree<K,V> ) {
		if ( bst == null ) {
			return 0;
		} else {
			return 1 + max( recHeight( bst.left ), recHeight( bst.right ));
		}
	}

	static function recEach<K,V>( bst: AATree<K,V>, f: K->V->Void ) {
		if ( bst != null ) {
			recEach( bst.left, f );
			f( bst.key, bst.value );
			recEach( bst.right, f );
		}
	}

	static function recFilter<K,V>( bst: AATree<K,V>, p: K->V->Bool ) {
		if ( bst != null ) {
			if ( p( bst.key, bst.value )) {
				return newNode( bst.key, bst.value, recFilter( bst.left, p ), recFilter( bst.right, p ), bst.level );
			} else {
				return recFilter( recRemove( bst, bst.key ), p );
			}
		} else {
			return null;
		}
	}

	static function recFoldl<K,V,T>( bst: AATree<K,V>, f: K->V->T->T, acc: T ) {
		if ( bst != null ) {
			return recFoldl( bst.right, f, recFoldl( bst.left, f, f( bst.key, bst.value, acc )));
		} else {
			return acc;
		}
	}

	static function recFoldr<K,V,T>( bst: AATree<K,V>, f: K->V->T->T, acc: T ) {
		if ( bst != null ) {
			return recFoldr( bst.left, f, recFoldr( bst.right, f, f( bst.key, bst.value, acc )));
		} else {
			return acc;
		}
	}

	static function recCount<K,V>( bst: AATree<K,V>, p: K->V->Bool ) {
		if ( bst != null ) {
			return (p( bst.key, bst.value ) ? 1 : 0) + recCount( bst.left, p ) + recCount( bst.right, p );
		} else {
			return 0;
		}
	}
}
