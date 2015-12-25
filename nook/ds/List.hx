package nook.ds;

enum ListAdt<T> {
	Cons( head: T, tail: ListAdt<T> );
	Nil;
}

class List<T> {
	public static inline function cons<T>( head: T, tail: ListAdt<T> ) return Cons( head, tail );
	public static inline function car<T>( lst: ListAdt<T> ) return switch ( lst ) { case Cons(head,_): head; case Nil: throw "Empty list";}
	public static inline function cdr<T>( lst: ListAdt<T> ) return switch ( lst ) { case Cons(_,tail): tail; case Nil: throw "Empty list";}
	public static inline function isNil<T>( lst: ListAdt<T> ) return lst == Nil;
	public static inline function cddr<T>( lst: ListAdt<T> ) return cdr( cdr( lst ));
	public static inline function cadr<T>( lst: ListAdt<T> ) return car( cdr( lst ));

	public static function toList<T>( it: Iterable<T> ) {
		var lst = Nil;
		for ( v in it ) {
			lst = Cons( v, lst );
		}	
		return reverse( lst );
	}

	static function pushToArray<T>( value: T, array: Array<T> ): Array<T> {
		array.push( value );
		return array;
	}

	public static function toArray<T>( lst: ListAdt<T> ): Array<T> {	
		return foldr( lst, [], pushToArray );
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
		case Nil: throw "Empty list";	
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
		case Nil: Nil;
	}

	public static function foldr<T,V>( lst: ListAdt<T>, acc: V, f: T->V->V ) {
		return foldl( reverse( lst ), acc, f );
	}

	public static function reverse<T>( lst: ListAdt<T> ) {
		return foldl( lst, Nil, cons );
	}

	public static function head<T>( lst: ListAdt<T>, index: Int ) return switch( lst ) {
		case Cons(head_,tail) if ( index <= 0 ): Cons(head_,Nil);
		case Cons(head_,tail): Cons(head_,head( tail, index - 1 ));
		case Nil: throw "Empty list"; 
	}

	public static function tail<T>( lst: ListAdt<T>, index: Int ) return switch( lst ) {
		case Cons(_) | Nil if ( index <= 0 ): Nil;
		case Cons(head,tail_): Cons(head,tail( tail_, index - 1 ));
		case Nil: throw "Empty list"; 
	}

	public static function unique<T>( lst: ListAdt<T>, checked: Dict<T,Bool> = null ) return switch( lst ) {
		case Cons(head,tail) if ( !Dict.exists( checked, head )): Cons(head,unique( tail, Dict.set( checked, head, true )));
		case Cons(head,tail): unique( tail, checked );
		case Nil: Nil;
	}

	public static function partition<T>( lst: ListAdt<T>, p: T->Bool ) {
		foldr( lst, new Pair( Nil, Nil ), function( v, acc ) {
			return p( v ) ? new Pair(Cons(v,acc.first), acc.second) : new Pair(acc.first, Cons(v,acc.second));
		});
	}
}
