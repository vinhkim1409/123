grammar CSlang;

@lexer::header {
from lexererr import *
}

options{
	language=Python3;
}

program: decllist  EOF ;
decllist: classdecl decllist | ;

//class declaration
classdecl: CLASS superpart ID LP memberlist RP ; // may be block class
memberlist: blockclass memberlist|;
blockclass: vardecl | funcdecl;

superpart: ID ARROW |;

// variable declaration
vardecl: mutability decl SEMI;
decl: vardeclrecbase| vardeclrec;
vardeclrecbase: idlist DDOT typlist;
vardeclrec: ID COMMA vardeclrec COMMA expr| basecase;
basecase: ID DDOT typlist EQUAL_OP expr;
mutability: CONST | VAR;

idlist:ID COMMA idlist | ID ;
typlist: typ_not_void | array_type | class_typ ;
typ_not_void: INT | FLOAT | BOOL | STRING;
array_type: LBS INTLIT RBS typ_not_void;
class_typ:ID;

// Method declaration
funcdecl: FUNC  funcprime ;
funcprime: funcbase | funcconstruct ;
funcbase: ID LB paramlist RB DDOT (typlist| VOID) blockstmt;
funcconstruct: CONSTRUCTOR LB paramlist RB blockstmt;
paramlist: paramprime | ;
paramprime: param COMMA paramprime | param;
param: idlist DDOT typlist;


//  expr
expr: expr1 CONCAT_OP expr1 | expr1;
expr1: expr2 (EQUALTO_OP | NOTEQUAL_OP | LESS_OP | GREATER_OP |LESSEQUAL_OP |GREATEREQUAL_OP ) expr2 | expr2;
expr2: expr2 (AND_OP | OR_OP ) expr3 |expr3;
expr3: expr3 (ADD_OP | MINUS_OP ) expr4 | expr4;
expr4: expr4 (MUL_OP | DIV_OP | BS_OP | MOD_OP) expr5| expr5;
expr5: NOT_OP expr5 | expr6;
expr6: MINUS_OP expr6 | expr7;
expr7: expr_index  | expr8;
expr_index: expr8 LBS exprlist RBS;
expr8: expr8 DOT ID |expr8 LB exprlist RB | expr9; // instance access 
expr9: (ID DOT)? ID | expr9 LB exprlist RB| expr10; // static access
expr10: 'new' creat_typ LB exprlist RB| expr11; // Object create
creat_typ: ID | INT;// type
expr11: ID | INTLIT | FLOATLIT | STRINGLIT | BOOLEANLIT | subexpr | SELF| array_lit; // con them vai cai nua
array_lit: LBS array_decl RBS;
array_decl: expr array_list;
array_list: COMMA expr array_list |;
subexpr: LB expr RB;

id_class: ID DOT | ;
instan_invo: expr8 LB exprlist RB; 
static_invo: expr9 LB exprlist RB ; 
exprlist: exprprime |;
exprprime: expr COMMA exprprime | expr;

// statements
stmt: assignstmt SEMI | ifstmt | forstmt | breakstmt | continuestmt | returnstmt | blockstmt |methodinvostmt;
assignstmt:(ID | expr7) ASSIGN_OP expr;
ifstmt: IF prestmt expr stmt elsestmt;
prestmt:stmt | ;
elsestmt:ELSE stmt |;

forstmt: FOR ID ASSIGN_OP expr SEMI expr SEMI ID ASSIGN_OP expr stmt;
breakstmt: BREAK SEMI;
continuestmt: CONTINUE SEMI;
returnstmt: RETURN expr? SEMI;
methodinvostmt: (instan_invo | static_invo) SEMI;
blockstmt: LP (stmtlist) RP;
stmtlist: stmtprime | ;
stmtprime: stmtblocks stmtprime | stmtblocks;
stmtblocks: stmt | vardecl;


fragment DECPART: DOT Digits;
fragment EXPPART: [eE] [+-]? Digits;
fragment Letter: [a-zA-Z]|'_';
fragment Digit:[0-9];
fragment Digits:Digit+;
fragment StringChar: ~[\b\f\r\n] | EscapeSeq ;
fragment EscapeSeq: '\\' [btnfr"'\\] ;
INTLIT:Digits;
FLOATLIT:Digits (DECPART? EXPPART| DECPART EXPPART?);
BOOLEANLIT:TRUE | FALSE;
STRINGLIT   :'"' ('\\' [bfrnt"\\] | ~[\b\f\r\n\t"\\] )* '"'
			{
				self.text = self.text[1:-1]
			}
			;


//operators
	ADD_OP:'+';
	MINUS_OP:'-';
	MUL_OP:'*';
	DIV_OP:'/';
	BS_OP:'++';
	NOT_OP:'!';
	AND_OP:'&&';
	OR_OP:'||';
	EQUALTO_OP:'==';
	EQUAL_OP:'=';
	NOTEQUAL_OP:'!=';
	LESS_OP:'<';
	LESSEQUAL_OP:'<=';
	GREATER_OP:'>';
	GREATEREQUAL_OP:'>=';
	ASSIGN_OP:':=';
	CONCAT_OP:'^';
	MOD_OP:'%';
	ARROW:'<-';
//Separators
	LB:'(';
	RB:')';
	LBS:'[';
	RBS:']';
	DOT:'.';
	COMMA:',';
	SEMI:';';
	DDOT:':';
	LP:'{';
	RP:'}';

//keyword
	BREAK:'break';
	CONTINUE:'continue';
	IF:'if';
	ELSE:'else';
	FOR:'for';
	TRUE:'true';
	FALSE:'false';
	INT:'int';
	FLOAT:'float';
	BOOL:'bool';
	STRING:'string';
	RETURN:'return';
	NULL:'null';
	CLASS:'class';
	CONSTRUCTOR:'constructor';
	VAR:'var';
	SELF:'self';
	NEW:'new';
	VOID:'void';
	CONST:'const';
	FUNC:'func';


ID: (Letter|[@]) (Letter | Digit )*;

WS : [ \t\r\n\\\f\b]+ -> skip ; // skip spaces, tabs, newlines
COMMENTLINE: '//' ~ [\n\r\t\f]* ->skip;
COMMENTBLOCK: '/*' .*? '*/' ->skip;

fragment Esc_illigal: '\\' ~[btnrf"'\\] ;
ILLEGAL_ESCAPE: '"' StringChar* Esc_illigal 
{
	t = self.text
	raise IllegalEscape(t[1:])
};
UNCLOSE_STRING : '"' ( ~[\b\f\r\t\n"\\] | '\\' [bfrnt"\\])*
				{
					raise UncloseString(self.text[1:])
				}
				;
ERROR_CHAR: . {raise ErrorToken(self.text)};