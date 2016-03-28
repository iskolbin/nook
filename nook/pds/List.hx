package nook.pds;

enum ListAdt<T> {
	Cons( head: T, tail: ListAdt<T> );
	Nil;
}

class List<T> {
	public static inline function cons<T>( head: T, tail: ListAdt<T> ) return Cons( head, tail );
	public static inline function car<T>( lst: ListAdt<T> ) return switch ( lst ) { case Cons(head,_): head; case Nil: throw "Empty list";}
	public static inline function cdr<T>( lst: ListAdt<T> ) return switch ( lst ) { case Cons(_,tail): tail; case Nil: throw "Empty list";}
	public static inline function cddr<T>( lst: ListAdt<T> ) return cdr( cdr( lst ));
	public static inline function cadr<T>( lst: ListAdt<T> ) return car( cdr( lst ));
	public static inline function isNil<T>( lst: ListAdt<T> ) return lst == Nil;

	public static function toList<T>( it: Iterable<T> ) {
		var lst = Nil;
		for ( v in it ) {
			lst = Cons( v, lst );
		}	
		return reverse( lst );
	}

	public static function toArray<T>( lst: ListAdt<T> ): Array<T> {	
		function pushToArray<T>( value: T, array: Array<T> ): Array<T> {
			array.push( value );
			return array;
		}

		return foldl( lst, [], pushToArray );
	}

	public static function get<T>( lst: ListAdt<T>, index: Int ) return switch( lst ) {
		case Cons(head,_) if ( index <= 0 ): head;
		case Cons(head,tail): get( tail, index - 1 );
		case Nil: throw "Empty list";
	}

	public static function set<T>( lst: ListAdt<T>, index: Int, value: T ) return switch( lst ) {	
		case Cons(_,tail) if ( index <= 0 ): Cons( value, tail );
		case Cons(_,tail): set( tail, index - 1, value );
		case Nil if ( index == 0 ): Cons( value, Nil );
		case Nil: throw "Empty list";
	}

	public static function remove<T>( lst: ListAdt<T>, value: T ) return switch( lst ) {
		case Cons(head,tail) if ( head == value ): remove( tail, value );
		case Cons(head,tail): Cons(head,remove( tail, value ));
		case Nil: Nil;
	}

	public static function map<T,V>( lst: ListAdt<T>, f: T->V ) return switch( lst ) {
		case Cons(head,tail): Cons(f( head ),map( tail, f ));
		case Nil: Nil;
	}

	public static function filter<T>( lst: ListAdt<T>, p: T->Bool ) return switch( lst ) {
		case Cons(head,tail) if (p(head)): Cons(head,filter( tail, p ));
		case Cons(_,tail): filter( tail, p );
		case Nil: Nil;
	}

	public static function foldl<T,V>( lst: ListAdt<T>, acc: V, f: T->V->V ) return switch( lst ){
		case Cons(head,tail): foldl( tail, f( head, acc ), f );
		case Nil: acc;
	}

	public static function foldr<T,V>( lst: ListAdt<T>, acc: V, f: T->V->V ) {
		return foldl( reverse( lst ), acc, f );
	}

	public static function reverse<T>( lst: ListAdt<T> ) {
		return foldl( lst, Nil, cons );
	}

	public static function contains<T>( lst: ListAdt<T>, v: T ): Bool return switch ( lst ) {
		case Cons(head,tail) if (head == v): true;
		case Cons(_,tail): contains( tail, v );
		case Nil: false;
	}

	public static function head<T>( lst: ListAdt<T>, index: Int ) return switch( lst ) {
		case Cons(head_,tail) if ( index <= 0 ): Cons(head_,Nil);
		case Cons(head_,tail): Cons(head_,head( tail, index - 1 ));
		case Nil: throw "Empty list"; 
	}

	public static function tail<T>( lst: ListAdt<T>, index: Int ) return switch( lst ) {
		case _ if ( index <= 0 ): lst;
		case Cons(_,tail_): tail( tail_, index - 1 );
		case Nil: throw "Empty list";
	}

	static function doUnique<T>( v: T, acc: ListAdt<T> ): ListAdt<T> {
		return contains( acc, v ) ? acc : Cons( v, acc );
	}

	public static function unique<T>( lst: ListAdt<T> ) {
		return foldr( lst, Nil, doUnique );
	}

	static function doLength<T>( v: T, acc: Int ): Int {
		acc++;
		return acc;
	}
	
	public static function length<T>( lst: ListAdt<T> ): Int {
		return foldl( lst, 0, doLength );
	}
}
