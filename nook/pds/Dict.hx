package nook.pds;

enum DictAdt<K,V> {
	Tree( kv: Pair<K,V>, left: DictAdt<K,V>, right: DictAdt<K,V>, level: Int );
	Nil;
}

class Dict {	
	public static inline function compare<K>( a: K, b: K ) {
		return Reflect.compare( a, b );
	}

	static inline function balance<K,V>( dict: DictAdt<K,V> ) return switch ( dict ) {
		case Tree(x,Tree(y,a,b,n),c,n2) if (n == n2): Tree(x,a,Tree(y,b,c,n),n);
		case Tree(x,a,Tree(y,b,Tree(z,c,d,n2),n3),n) if (n == n2 && n2 == n3): Tree(y,Tree(x,a,b,n),Tree(z,c,d,n),n+1);
		case _: dict;
	}

	public static function set<K,V>( dict: DictAdt<K,V>, k: K, v: V ) return switch( dict ) {
		case Nil: Tree(new Pair(k,v),Nil,Nil,1);
		case Tree(x,a,b,n): 
			var cmp = compare( k, x.a );
			if ( cmp == 0 ) Tree(new Pair(k,v),a,b,n);
			else if ( cmp < 0 ) balance(Tree(x,set( a, k, v ),b,n));
			else balance( Tree(x,a,set( b, k, v ),n));
	}

	public static function get<K,V>( dict: DictAdt<K,V>, k: K ) return switch( dict ) {
		case Nil: null;
		case Tree(x,a,b,n): 
			var cmp = compare( k, x.a );
			if ( cmp == 0 ) x.b;
			else if ( cmp < 0 ) get( a, k );
			else get( b, k );
	}

	public static function leftmost<K,V>( dict: DictAdt<K,V> ) return switch( dict ) {
		case Tree(_,a,_,_) if ( a != Nil ): leftmost( a );
		case _: dict;
	}

	public static function rightmost<K,V>( dict: DictAdt<K,V> ) return switch( dict ) {
		case Tree(_,_,b,_) if ( b != Nil ): rightmost( b );
		case _: dict;
	}
	
	public static inline function predecessor<K,V>( dict: DictAdt<K,V> ) return switch( dict ) {
		case Nil: Nil;
		case Tree(_,a,_,_): rightmost( a );
	}

	public static inline function successor<K,V>( dict: DictAdt<K,V> ) return switch( dict ) {
		case Nil: Nil;
		case Tree(_,_,b,_): leftmost( b );
	}

	static inline function min( x: Int, y: Int ) {
		return x < y ? x : y;
	}
	
	static inline function max( x: Int, y: Int ) {
		return x > y ? x : y;
	}

	public static inline function shouldbe<K,V>( dict: DictAdt<K,V> ) return switch( dict ) {
		case Tree(_,Tree(_,_,_,m),Tree(_,_,_,l),_): min( m, l ) + 1;
		case _: 1;	
	}

	public static inline function decrease<K,V>( dict: DictAdt<K,V> ): DictAdt<K,V> {
		var s = shouldbe(dict);
		return switch ( dict ) {
			case Tree(x,a,Tree(z,e,f,l),n) if (s < l): Tree(x,a,Tree(z,e,f,s),s);
			case Tree(x,a,b,n) if (s < n): Tree(x,a,b,s);
			case _: dict;
		}
	}

	public static function remove<K,V>( dict: DictAdt<K,V>, k: K ) return switch( dict ) {
		case Nil: Nil;
		case Tree(x,a,b,n): 
			var cmp = compare( k, x.a );
			if ( cmp == 0 ) {
				if ( a == Nil ) switch ( successor( dict )) {
					case Nil: Nil;
					case Tree(y,c,d,m): balance( decrease( Tree(y,Nil,remove(b,y.a),n) ));
				}
				else switch( predecessor( dict )) {
					case Nil: Nil;
					case Tree(y,c,d,m): balance( decrease( Tree(y,remove(a,y.a),b,n) ));
				}
			}
			else if ( cmp < 0 ) balance( decrease( Tree(x,remove( a, k ),b,n) ));
			else balance( decrease( Tree(x,a,remove( b, k ),n) ));
	}

	public static function map<K,V,T>( dict: DictAdt<K,V>, f: Pair<K,V>->T ): DictAdt<K,T> return switch( dict ) {
		case Tree(x,a,b,n): Tree(new Pair(x.a,f(x)),map( a, f ),map( b, f ),n);
		case Nil: Nil;
	}

	public static function filter<K,V>( dict: DictAdt<K,V>, p: Pair<K,V>->Bool ) return switch( dict ) {
		case Tree(x,a,b,n): p( x ) ? Tree(x,filter(a,p),filter(b,p),n) : filter(remove(dict,x.a),p);
		case Nil: Nil;
	}

	public static function foldl<K,V,T>( dict: DictAdt<K,V>, acc: T, f: Pair<K,V>->T->T ): T return switch( dict ) {
		case Tree(x,a,b,n): foldl( b, foldl( a, f( x, acc ), f ), f );
		case Nil: acc;
	}
	
	public static function foldr<K,V,T>( dict: DictAdt<K,V>, acc: T, f: Pair<K,V>->T->T ): T return switch( dict ) {
		case Tree(x,a,b,n): foldr( a, foldr( b, f( x, acc ), f ), f );
		case Nil: acc;
	}

	public static function height<K,V>( dict: DictAdt<K,V> ) return switch( dict ) {
		case Tree(x,a,b,n): 1 + max( height(a), height(b) );
		case Nil: 0;
	}

	public static function length<K,V>( dict: DictAdt<K,V> ) return switch( dict ) {
		case Tree(x,a,b,n): 1 + length( a ) + length( b );
		case Nil: 0;
	}

	public static function count<K,V>( dict: DictAdt<K,V>, p: Pair<K,V>->Bool ) return switch( dict ) {
		case Tree(x,a,b,n): (p( x ) ? 1 : 0) + count( a, p ) + count( b, p );
		case Nil: 0;
	}

	public static function all<K,V>( dict: DictAdt<K,V>, p: Pair<K,V>->Bool ) return switch( dict ) {
		case Tree(x,a,b,n): p( x ) ? all( a, p ) && all( b, p ) : false;
		case Nil: true;
	}

	public static function any<K,V>( dict: DictAdt<K,V>, p: Pair<K,V>->Bool ) return switch( dict ) {
		case Tree(x,a,b,n): p( x ) ? true : any( a, p ) || any( b, p );
		case Nil: false;
	}

	static function doToString<K,V>( dict: DictAdt<K,V>, ident: String, buffer: StringBuf ): StringBuf {
		switch ( dict ) {
			case Nil: 
				buffer.add( ident );
				buffer.add( "()" );
			case Tree(x,a,b,n):
				buffer.add( ident );
				buffer.add( "(" );
				buffer.add( Std.string( x.a ));
				buffer.add( " => " );
				buffer.add( Std.string( x.b ));
				buffer.add( ")\n" );
				doToString( a, ident+" ", buffer );
				buffer.add( "\n" );
				doToString( b, ident+" ", buffer );
		}
		return buffer;
	}

	public static function toString<K,V>( dict: DictAdt<K,V>, ident: String = "" ) {
		
		return doToString( dict, "", new StringBuf()).toString();
		//case Nil: ident + "NIL";
		//case Tree(x,a,b,n): ident + 'T $x/$n\n${toString(a,ident+" ")}\n${toString(b,ident+" ")}'; 
	}
}
