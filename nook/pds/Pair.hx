package nook.pds;

class Pair<A,B> {
	public var a(default,null): A;
	public var b(default,null): B;

	public inline function new( a: A, b: B ) {
		this.a = a;
		this.b = b;
	}

	public function toString() {
		return '($a . $b)';
	}
}
