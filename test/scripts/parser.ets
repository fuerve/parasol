statement() { ; }
statement() { a; }
statement() { "{ }" }
statement() { "{ a; }" }
statement() { "{ a; a; }" }
statement() { break; }
statement() { case a: b; }
statement(expect: fail, message: UNEXPECTED_RC) { "case a: }" }
statement(expect: fail, message: UNEXPECTED_RC) { "default: }" }
statement() { continue; }
statement() { default: a; }
statement() { "do a; while (b);" }
statement() { "for (a; b; c) d;" }
statement() { "for (; b; c) d;" }
statement() { "for (a;; c) d;" }
statement() { "for (a; b;) d;" }
statement() { "for (;; c) d;" }
statement() { "for (; b;) d;" }
statement() { "for (a;;) d;" }
statement() { "for (;;) d;" }
statement() { "for (a  b : c) d;" }
statement() { "if (a) b;" }
statement() { "if (a) b; else c;" }
statement() { "if (a) b; else if (c) d;" }
statement() { "if (a) if (b) c; else d; else e;" }
statement() { return; }
statement() { return a; }
statement() { "switch (a) b;" }
statement() { "while (a) b;" }
statement() { "@n switch (a) b;" }
statement() { "@n while (a) b;" }
statement() { "int main(string[] args){a;}" }
statement() { "int<64> x;" }
statement() { "abstract int x();" }
statement() { "class q<class T>{}" }
statement() { "class q{}" }
statement() { "class q{}" }
statement() { "public int x;" }
statement() { "protected int x;" }
statement() { "private int x;" }
statement() { "int x;" }
statement() { "@c public int x;" }
statement() { "@c protected int x;" }
statement() { "@c private int x;" }
statement() { "@c int x;" }
statement() { "final class q{a;b;}" }
statement() { "final class q{a;b;}" }
statement() { "class q{a;b;}" }
statement() { "class q extends a {}" }
statement() { "class q implements a {}" }
statement() { "class q extends a implements b {}" }
statement() { "@c class q{}" }
statement() { "@c class q extends a {}" }
statement() { "@c class q implements a {}" }
statement() { "@c class q extends a implements b {}" }
statement() { "@c @d class q extends a implements b {}" }
statement() { "@c() class q{}" }
statement() { "@c() class q extends a {}" }
statement() { "@c() class q implements a {}" }
statement() { "@c() class q extends a implements b {}" }
statement() { "@c(d) class q{}" }
statement() { "@c(d) class q extends a {}" }
statement() { "@c(d) class q implements a {}" }
statement() { "@c(d) class q extends a implements b {}" }
statement() { "enum a{b}" }
statement() { "enum a{b,c}" }
statement() { "enum a{b; int x;}" }
statement() { "@c enum a{b}" }
statement() { "@c enum a{b,c}" }
statement() { "@c enum a{b; int x;}" }
statement() { "import x = z:y.w;" }
statement() { "import z:y.w;" }
statement() { "namespace y:x;" }
statement() { "import x = z.b:y.a.w;" }
statement() { "import z.b:y.a.w;" }
statement() { "namespace y.b:x.a;" }
statement() { "namespace y.b.c.d.e:x.a;" }
statement() { "class a { static int x; }" }
statement() { "class a { private static int x; }" }

statement(expect: fail, message: NOT_EXPECTING_ELSE) { "else a;" }
statement(expect: recovered, message: EXPECTING_TERM) { "{ for (int i : array) ; return }" }
statement(expect: fail, message: UNEXPECTED_EOF) { a }
statement(expect: recovered, message: UNEXPECTED_EOF) { "{" }
statement(expect: fail, message: UNEXPECTED_RC) { "}" }
statement(expect: fail, message: BREAK_NO_SEMI) { break }
statement(expect: fail, message: EXPECTING_TERM) { case }
statement(expect: fail, message: CASE_NO_CO) { case a }
statement(expect: fail, message: UNEXPECTED_EOF) { case a: }
statement(expect: fail, message: UNEXPECTED_EOF) { case a: b }
statement(expect: fail, message: EXPECTING_TERM) { case : b; }
statement(expect: fail, message: CASE_NO_CO) { case a b; }
statement(expect: fail) { continue }
statement(expect: fail) { default }
statement(expect: fail, message: UNEXPECTED_EOF) { default: }
statement(expect: fail, message: UNEXPECTED_EOF) { default: a }
statement(expect: fail) { default a; }
statement(expect: fail) { do }
statement(expect: fail) { "do a" }
statement(expect: fail) { "do a;" }
statement(expect: fail) { "do a; while" }
statement(expect: fail) { "do a; while (" }
statement(expect: fail) { "do a; while (b" }
statement(expect: fail, message: DO_WHILE_NO_SEMI) { "do a; while (b)" }
statement(expect: fail) { "do a while (b);" }
statement(expect: fail) { "do a; (b);" }
statement(expect: fail) { "do a; while b);" }
statement(expect: fail) { "do a; while ();" }
statement(expect: fail) { "do a; while (b;" }
statement(expect: fail) { for }
statement(expect: fail) { "for (" }
statement(expect: fail) { "for (a" }
statement(expect: fail) { "for (a;" }
statement(expect: fail) { "for (a; b" }
statement(expect: fail) { "for (a; b;" }
statement(expect: fail) { "for (a; b; c" }
statement(expect: fail) { "for (a; b; c)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "for (a; b; c) d" }
statement(expect: fail) { "for a; b; c) d;" }
statement(expect: fail) { "for (a b; c) d;" }
statement(expect: fail) { "for (a; b c) d;" }
statement(expect: fail) { "for (a; b; c d;" }
statement(expect: fail) { "for (;" }
statement(expect: fail) { "for (; b" }
statement(expect: fail) { "for (; b;" }
statement(expect: fail) { "for (; b; c" }
statement(expect: fail) { "for (; b; c)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "for (; b; c) d" }
statement(expect: fail) { "for ; b; c) d;" }
statement(expect: fail) { "for (b; c) d;" }
statement(expect: fail) { "for (; b c) d;" }
statement(expect: fail) { "for (; b; c d;" }
statement(expect: fail) { "for (a;;" }
statement(expect: fail) { "for (a;; c" }
statement(expect: fail) { "for (a;; c)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "for (a;; c) d" }
statement(expect: fail) { "for (a;; c d;" }
statement(expect: fail) { "for (a; b;)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "for (a; b;) d" }
statement(expect: fail) { "for (;;" }
statement(expect: fail) { "for (;; c" }
statement(expect: fail) { "for (;; c)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "for (;; c) d" }
statement(expect: fail) { "for (; c) d;" }
statement(expect: fail) { "for (;; c d;" }
statement(expect: fail) { "for (; b;)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "for (; b;) d" }
statement(expect: fail) { "for (; b; d;" }
statement(expect: fail) { "for (a;;)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "for (a;;) d" }
statement(expect: fail) { "for (a;; d;" }
statement(expect: fail) { "for (;;)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "for (;;) d" }
statement(expect: fail) { "for (;) d;" }
statement(expect: fail) { "for (a  b" }
statement(expect: fail) { "for (a  b :" }
statement(expect: fail) { "for (a  b : c" }
statement(expect: fail) { "for (a  b : c)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "for (a  b : c) d" }
statement(expect: fail) { "for a  b : c) d;" }
statement(expect: fail) { "for (a  b c) d;" }
statement(expect: fail) { "for (a  b : c d;" }
statement(expect: fail) { if }
statement(expect: fail) { "if (" }
statement(expect: fail) { "if (a" }
statement(expect: fail) { "if (a)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "if (a) b" }
statement(expect: fail) { "if (a) b; else" }
statement(expect: fail, message: UNEXPECTED_EOF) { "if (a) b; else c" }
statement(expect: fail) { "if a) b; else c;" }
statement(expect: fail) { "if (a b; else c;" }
statement(expect: fail) { "if (a) b else c;" }
statement(expect: fail) { "else c;" }
statement(expect: fail) { return }
statement(expect: fail) { return a }
statement(expect: fail) { "switch" }
statement(expect: fail) { "switch (" }
statement(expect: fail) { "switch (a" }
statement(expect: fail) { "switch (a)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "switch (a) b" }
statement(expect: fail) { "switch a) b;" }
statement(expect: fail) { "switch (a b;" }
statement(expect: fail) { "while" }
statement(expect: fail) { "while (" }
statement(expect: fail) { "while (a" }
statement(expect: fail) { "while (a)" }
statement(expect: fail, message: UNEXPECTED_EOF) { "while (a) b" }
statement(expect: fail) { "while a) b;" }
statement(expect: fail) { "while (a b;" }
statement(expect: fail) { final }
statement(expect: fail) { abstract }
statement(expect: fail) { class }
statement(expect: fail) { class q }
statement(expect: fail) { class extends }
statement(expect: fail) { class q extends }
statement(expect: fail) { "class extends {}" }
statement(expect: fail) { "class q extends {}" }
statement(expect: fail) { class extends a }
statement(expect: fail) { class q extends a }
statement(expect: fail) { "class extends a {" }
statement(expect: recovered) { "class q extends a {" }
statement(expect: fail) { class implements }
statement(expect: fail) { class q implements }
statement(expect: fail) { class implements a }
statement(expect: fail) { class q implements a }
statement(expect: fail) { "class implements a {" }
statement(expect: recovered) { "class q implements a {" }
statement(expect: fail) { class extends a implements }
statement(expect: fail) { class q extends a implements }
statement(expect: fail) { class extends a implements b }
statement(expect: fail) { class q extends a implements b }
statement(expect: fail) { "class extends a implements b {" }
statement(expect: recovered) { "class q extends a implements b {" }
statement(expect: fail) { "enum" }
statement(expect: fail) { "enum a" }
statement(expect: fail) { "enum {b}" }
statement(expect: fail) { "enum {}" }
statement(expect: recovered) { "enum a{" }
statement(expect: recovered) { "enum a{b" }
statement(expect: recovered) { "enum a{b," }
statement(expect: recovered) { "enum a{b,c" }
statement(expect: recovered) { "enum a{b c" }
statement(expect: fail) { "enum {b; x;}" }
statement(expect: recovered) { "enum a{b; x;" }
statement(expect: recovered) { "enum a{b; x" }
statement(expect: recovered) { "enum a{; x;}" }
statement(expect: recovered) { "enum a{b, c; x}" }
statement(expect: fail) { "int main(" }
statement(expect: fail) { "int main(a" }
statement(expect: fail) { "int main(a)" }
statement(expect: recovered) { "int main(a b) {" }
statement(expect: fail) { "int main(a," }
statement(expect: fail) { "int main(a b" }
statement(expect: fail) { "int main(a b)" }
statement(expect: recovered) { "int main(a b) {" }
statement(expect: fail) { "int main(a b," }
statement(expect: fail) { "int main(a b, c" }
statement(expect: fail) { "int main(a b, c d" }
statement(expect: fail) { "int main(a b, c d)" }
statement(expect: recovered) { "int main(a b, c d) {" }
statement(expect: fail) { @a }
statement(expect: fail) { "import a" }
statement(expect: fail) { "import a =" }
statement(expect: fail) { "import a = y" }
statement(expect: fail) { "import a = y(" }
statement(expect: fail) { "import a = y(z" }
statement(expect: fail) { "import a = y(z)" }
statement(expect: fail) { "import a = y(z)." }
statement(expect: fail) { "import a = y(z).w" }
statement(expect: fail) { "import y(" }
statement(expect: fail) { "import y(z" }
statement(expect: fail) { "import y(z)" }
statement(expect: fail) { "import y(z)." }
statement(expect: fail) { "import y(z).w" }
statement(expect: fail) { "namespace a" }
statement(expect: fail) { "namespace a(" }
statement(expect: fail) { "namespace a(y" }
statement(expect: fail) { "namespace a(y)" }
statement(expect: fail) { "import x = y." }
statement(expect: fail) { "import x = y.a" }
statement(expect: fail) { "import x = y.a(" }
statement(expect: fail) { "import x = y.a(z" }
statement(expect: fail) { "import x = y.a(z." }
statement(expect: fail) { "import x = y.a(z.b" }
statement(expect: fail) { "import x = y.a(z.b)" }
statement(expect: fail) { "import x = y.a(z.b)." }
statement(expect: fail) { "import x = y.a(z.b).w" }
statement(expect: fail) { "import y." }
statement(expect: fail) { "import y.a" }
statement(expect: fail) { "import y.a(" }
statement(expect: fail) { "import y.a(z" }
statement(expect: fail) { "import y.a(z." }
statement(expect: fail) { "import y.a(z.b" }
statement(expect: fail) { "import y.a(z.b)" }
statement(expect: fail) { "import y.a(z.b)." }
statement(expect: fail) { "import y.a(z.b).w" }
statement(expect: fail) { "namespace x." }
statement(expect: fail) { "namespace x.a" }
statement(expect: fail) { "namespace x.a(" }
statement(expect: fail) { "namespace x.a(y" }
statement(expect: fail) { "namespace x.a(y." }
statement(expect: fail) { "namespace x.a(y.b" }
statement(expect: fail) { "namespace x.a(y.b)" }
statement(expect: fail) { "namespace x.a(y.b." }
statement(expect: fail) { "namespace x.a(y.b.c" }
statement(expect: fail) { "namespace x.a(y.b.c." }
statement(expect: fail) { "namespace x.a(y.b.c.d" }
statement(expect: fail) { "namespace x.a(y.b.c.d." }
statement(expect: fail) { "namespace x.a(y.b.c.d.e" }
statement(expect: fail) { "namespace x.a(y.b.c.d.e)" }
statement(expect: recovered) { "class a { private static }" }
statement(expect: recovered) { "class a { private static int }" }
statement(expect: recovered) { "class a { private static int x }" }
statement(expect: recovered) { "class a { private static" }
statement(expect: recovered) { "class a { private static int" }
statement(expect: recovered) { "class a { private static int x" }

// Basic simple terms

expression() { a }
expression() { 1 }
expression() { 2.0 }
expression() { "'a'" }
expression() { '"a"' }
expression() { this }
expression() { super }
expression() { true }
expression() { false }
expression() { null }

// Class constant variations

expression() { "class{}" }
expression() { "class extends a {}" }
expression() { "class implements a {}" }
expression() { "class extends a implements b {}" }

expression(expect: fail, message: BAD_TOKEN) { class $ }

expression(expect: fail) { class }
expression(expect: fail) { class extends }
expression(expect: fail) { "class extends {}" }
expression(expect: fail) { class a }
expression(expect: fail) { "class a {}" }
expression(expect: fail) { class extends a }
expression(expect: fail) { "class extends a {" }
expression(expect: fail) { class implements }
expression(expect: fail) { class implements a }
expression(expect: fail) { "class implements a {" }
expression(expect: fail) { class extends a implements }
expression(expect: fail) { class extends a implements b }
expression(expect: fail) { "class extends a implements b {" }
expression(expect: fail) { @a }

// Unary operators

expression() { +a }
expression() { -a }
expression() { ~a }
expression() { !a }
expression() { &a }
expression() { *a }
expression() { ++a }
expression() { --a }
expression() { new a }
expression() { delete a }

// Invalid unary operators

expression(expect: fail, message: EXPECTING_TERM) { ,a }
expression(expect: fail, message: EXPECTING_TERM) { /a }
expression(expect: fail, message: EXPECTING_TERM) { %a }
expression(expect: fail, message: EXPECTING_TERM) { |a }
expression(expect: fail, message: EXPECTING_TERM) { ^a }
expression(expect: fail, message: EXPECTING_TERM) { <<a }
expression(expect: fail, message: EXPECTING_TERM) { >>a }
expression(expect: fail, message: EXPECTING_TERM) { >>>a }
expression(expect: fail, message: EXPECTING_TERM) { ..a }
expression(expect: fail, message: EXPECTING_TERM) { =a }
expression(expect: fail, message: EXPECTING_TERM) { +=a }
expression(expect: fail, message: EXPECTING_TERM) { -=a }
expression(expect: fail, message: EXPECTING_TERM) { *=a }
expression(expect: fail, message: EXPECTING_TERM) { /=a }
expression(expect: fail, message: EXPECTING_TERM) { %=a }
expression(expect: fail, message: EXPECTING_TERM) { &=a }
expression(expect: fail, message: EXPECTING_TERM) { |=a }
expression(expect: fail, message: EXPECTING_TERM) { ^=a }
expression(expect: fail, message: EXPECTING_TERM) { <<=a }
expression(expect: fail, message: EXPECTING_TERM) { >>=a }
expression(expect: fail, message: EXPECTING_TERM) { >>>=a }

expression(expect: fail, message: EXPECTING_TERM) { ===a }
expression(expect: fail, message: EXPECTING_TERM) { ==a }
expression(expect: fail, message: EXPECTING_TERM) { <a }
expression(expect: fail, message: EXPECTING_TERM) { >a }
expression(expect: fail, message: EXPECTING_TERM) { <=a }
expression(expect: fail, message: EXPECTING_TERM) { >=a }
expression(expect: fail, message: EXPECTING_TERM) { <>a }
expression(expect: fail, message: EXPECTING_TERM) { <>=a }
expression(expect: fail, message: EXPECTING_TERM) { !=a }
expression(expect: fail, message: EXPECTING_TERM) { !==a }
expression(expect: fail, message: EXPECTING_TERM) { !<a }
expression(expect: fail, message: EXPECTING_TERM) { !>a }
expression(expect: fail, message: EXPECTING_TERM) { !<=a }
expression(expect: fail, message: EXPECTING_TERM) { !>=a }
expression(expect: fail, message: EXPECTING_TERM) { !<>a }
expression(expect: fail, message: EXPECTING_TERM) { !<>=a }

// Suffix operators

expression() { a++ }
expression() { a-- }
expression() { a.b }
expression() { a.bytes }
expression() { a[b] }
expression() { a[b] }
expression() { "a[b]{ c }" }
expression() { "a[b]{ c, d }" }
expression() { a[b:] }
expression() { a[b:c] }
expression() { "a()" }
expression() { "a(b)" }
expression() { "a(b c)" }
expression() { "a(b, c)" }
expression() { "a(b c, d)" }
expression() { "a(b c, d e)" }
expression() { "a(@n b)" }
expression() { "a(@n b c)" }
expression() { "a(b, @n c)" }
expression() { "a(@n(x) @m b c, d)" }
expression() { "a(b c, @n d e)" }
expression() { "a<b>" }
expression() { "function {a;}" }
expression() { "function int {a;}" }
expression() { "function int (a b) {x;}" }
expression() { "function int (a) {a;}" }
expression() { "function int (a... b) {a;}" }
expression() { "function int (a b, c, d) {x;}" }
expression() { "function int (@n a b) {x;}" }
expression() { "function int (@n a) {a;}" }
expression() { "function int (a b, @n c, d) {x;}" }

expression(expect: fail) { ... }
expression(expect: fail) { a. }
expression(expect: fail) { .a }
expression(expect: fail) { bytes }
expression(expect: fail, message: EXPECTING_TERM) { a[ }
expression(expect: fail, message: EXPECTING_RS) { a[b }
expression(expect: fail) { "a[" }
expression(expect: fail) { "a[b" }
expression(expect: fail) { "a[b]{ " }
expression(expect: fail) { "a[b]{ c" }
expression(expect: fail) { "a[b]{ c, " }
expression(expect: fail) { "a[b]{ c, d" }
expression(expect: fail) { a[b: }
expression(expect: fail) { a[b:c }
expression(expect: fail) { "a<" }
expression(expect: fail) { "a<b" }
expression(expect: fail) { "function" }
expression(expect: fail) { "function {" }
expression(expect: fail) { "function int" }
expression(expect: fail) { "function int {" }
expression(expect: fail) { "function int (" }
expression(expect: fail) { "function int (a" }
expression(expect: fail) { "function int (@n" }
expression(expect: fail) { "function int (a b" }
expression(expect: fail) { "function int (@n a b" }
expression(expect: fail) { "function int (a b)" }
expression(expect: fail) { "function int (a b) {" }
expression(expect: fail) { "function int (a)" }
expression(expect: fail) { "function int (a) {" }
expression(expect: fail) { "function int (a b," }
expression(expect: fail) { "function int (a b, c" }
expression(expect: fail) { "function int (a b, @n c" }
expression(expect: fail) { "function int (a b, c," }
expression(expect: fail) { "function int (a b, c, d)" }
expression(expect: fail) { "function int (a b, c, d) {" }
expression(expect: fail) { "function +int {}" }
expression(expect: fail, message: EXPECTING_TERM) { @n a }

// Invalid suffix operators

expression(expect: fail, message: EXPECTING_TERM) { a, }
expression(expect: fail, message: EXPECTING_TERM) { a+ }
expression(expect: fail, message: EXPECTING_TERM) { a- }
expression(expect: fail, message: EXPECTING_TERM) { a* }
expression(expect: fail, message: EXPECTING_TERM) { a/ }
expression(expect: fail, message: EXPECTING_TERM) { a% }
expression(expect: fail, message: EXPECTING_TERM) { a& }
expression(expect: fail, message: EXPECTING_TERM) { a| }
expression(expect: fail, message: EXPECTING_TERM) { a^ }
expression(expect: fail, message: EXPECTING_TERM) { a<< }
expression(expect: fail, message: EXPECTING_TERM) { a >> }
expression(expect: fail, message: EXPECTING_TERM) { a >>> }
expression(expect: fail, message: EXPECTING_TERM) { a.. }
expression(expect: fail, message: EXPECTING_TERM) { a= }
expression(expect: fail, message: EXPECTING_TERM) { a+= }
expression(expect: fail, message: EXPECTING_TERM) { a-= }
expression(expect: fail, message: EXPECTING_TERM) { a*= }
expression(expect: fail, message: EXPECTING_TERM) { a/= }
expression(expect: fail, message: EXPECTING_TERM) { a%= }
expression(expect: fail, message: EXPECTING_TERM) { a&= }
expression(expect: fail, message: EXPECTING_TERM) { a|= }
expression(expect: fail, message: EXPECTING_TERM) { a^= }
expression(expect: fail, message: EXPECTING_TERM) { a<<= }
expression(expect: fail, message: EXPECTING_TERM) { a >>= }
expression(expect: fail, message: EXPECTING_TERM) { a >>>= }

expression(expect: fail, message: EXPECTING_TERM) { a=== }
expression(expect: fail, message: EXPECTING_TERM) { a== }
expression(expect: fail, message: EXPECTING_TERM) { a< }
expression(expect: fail, message: EXPECTING_TERM) { a > }
expression(expect: fail, message: EXPECTING_TERM) { a<= }
expression(expect: fail, message: EXPECTING_TERM) { a>= }
expression(expect: fail, message: EXPECTING_TERM) { a<> }
expression(expect: fail, message: EXPECTING_TERM) { a<>= }
expression(expect: fail, message: EXPECTING_TERM) { a!= }
expression(expect: fail, message: EXPECTING_TERM) { a!== }
expression(expect: fail, message: EXPECTING_TERM) { a!< }
expression(expect: fail, message: EXPECTING_TERM) { a!> }
expression(expect: fail, message: EXPECTING_TERM) { a!<= }
expression(expect: fail, message: EXPECTING_TERM) { a!>= }
expression(expect: fail, message: EXPECTING_TERM) { a!<> }
expression(expect: fail, message: EXPECTING_TERM) { a!<>= }

expression(expect: fail, message: EXPECTING_TERM) { a new }
expression(expect: fail, message: EXPECTING_TERM) { a delete }

// Parentheses 

expression() { "(a)" }

// Binary operators

expression() { a , b }
expression() { a + b }
expression() { a - b }
expression() { a * b }
expression() { a / b }
expression() { a % b }
expression() { a & b }
expression() { a | b }
expression() { a ^ b }
expression() { a << b }
expression() { a >> b }
expression() { a >>> b }
expression() { a .. b }
expression() { a = b }
expression() { a += b }
expression() { a -= b }
expression() { a *= b }
expression() { a /= b }
expression() { a %= b }
expression() { a &= b }
expression() { a |= b }
expression() { a ^= b }
expression() { a <<= b }
expression() { a >>= b }
expression() { a >>>= b }

expression() { a === b }
expression() { a == b }
expression() { a < b }
expression() { a > b }
expression() { a <= b }
expression() { a >= b }
expression() { a <> b }
expression() { a <>= b }
expression() { a != b }
expression() { a !== b }
expression() { a !< b }
expression() { a !> b }
expression() { a !<= b }
expression() { a !>= b }
expression() { a !<> b }
expression() { a !<>= b }

expression() { a new b || c }
expression() { a delete b }

// Invalid binary operators: the parses do not consume all tokens,
// but otherwise report no error messages

expression(expect: fail) { a ~ b }
expression(expect: fail) { a ++ b }
expression(expect: fail) { a -- b }
expression(expect: fail) { a : b }

// Ternary conditional operator

expression() { a ? b : c }
expression() { a ? b + c : d }
