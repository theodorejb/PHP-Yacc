%pure_parser
%expect 2

%right T_THROW
%left T_INCLUDE T_INCLUDE_ONCE T_EVAL T_REQUIRE T_REQUIRE_ONCE
%left ','
%left T_LOGICAL_OR
%left T_LOGICAL_XOR
%left T_LOGICAL_AND
%right T_PRINT
%right T_YIELD
%right T_DOUBLE_ARROW
%right T_YIELD_FROM
%left '=' T_PLUS_EQUAL T_MINUS_EQUAL T_MUL_EQUAL T_DIV_EQUAL T_CONCAT_EQUAL T_MOD_EQUAL T_AND_EQUAL T_OR_EQUAL T_XOR_EQUAL T_SL_EQUAL T_SR_EQUAL T_POW_EQUAL T_COALESCE_EQUAL
%left '?' ':'
%right T_COALESCE
%left T_BOOLEAN_OR
%left T_BOOLEAN_AND
%left '|'
%left '^'
%left T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG T_AMPERSAND_FOLLOWED_BY_VAR_OR_VARARG
%nonassoc T_IS_EQUAL T_IS_NOT_EQUAL T_IS_IDENTICAL T_IS_NOT_IDENTICAL T_SPACESHIP
%nonassoc '<' T_IS_SMALLER_OR_EQUAL '>' T_IS_GREATER_OR_EQUAL%left '.'
%left T_SL T_SR
%left '+' '-'
%left '*' '/' '%'
%right '!'
%nonassoc T_INSTANCEOF
%right '~' T_INC T_DEC T_INT_CAST T_DOUBLE_CAST T_STRING_CAST T_ARRAY_CAST T_OBJECT_CAST T_BOOL_CAST T_UNSET_CAST '@'
%right T_POW
%right '['
%nonassoc T_NEW T_CLONE
%token T_EXIT
%token T_IF
%left T_ELSEIF
%left T_ELSE
%left T_ENDIF
%token T_LNUMBER
%token T_DNUMBER
%token T_STRING
%token T_STRING_VARNAME
%token T_VARIABLE
%token T_NUM_STRING
%token T_INLINE_HTML
%token T_ENCAPSED_AND_WHITESPACE
%token T_CONSTANT_ENCAPSED_STRING
%token T_ECHO
%token T_DO
%token T_WHILE
%token T_ENDWHILE
%token T_FOR
%token T_ENDFOR
%token T_FOREACH
%token T_ENDFOREACH
%token T_DECLARE
%token T_ENDDECLARE
%token T_AS
%token T_SWITCH
%token T_MATCH
%token T_ENDSWITCH
%token T_CASE
%token T_DEFAULT
%token T_BREAK
%token T_CONTINUE
%token T_GOTO
%token T_FUNCTION
%token T_FN
%token T_CONST
%token T_RETURN
%token T_TRY
%token T_CATCH
%token T_FINALLY
%token T_THROW
%token T_USE
%token T_INSTEADOF
%token T_GLOBAL
%token T_STATIC T_ABSTRACT T_FINAL T_PRIVATE T_PROTECTED T_PUBLIC T_READONLY
%token T_PUBLIC_SET
%token T_PROTECTED_SET
%token T_PRIVATE_SET
%token T_VAR
%token T_UNSET
%token T_ISSET
%token T_EMPTY
%token T_HALT_COMPILER
%token T_CLASS
%token T_TRAIT
%token T_INTERFACE
%token T_ENUM
%token T_EXTENDS
%token T_IMPLEMENTS
%token T_OBJECT_OPERATOR
%token T_NULLSAFE_OBJECT_OPERATOR
%token T_DOUBLE_ARROW
%token T_LIST
%token T_ARRAY
%token T_CALLABLE
%token T_CLASS_C
%token T_TRAIT_C
%token T_METHOD_C
%token T_FUNC_C
%token T_PROPERTY_C
%token T_LINE
%token T_FILE
%token T_START_HEREDOC
%token T_END_HEREDOC
%token T_DOLLAR_OPEN_CURLY_BRACES
%token T_CURLY_OPEN
%token T_PAAMAYIM_NEKUDOTAYIM
%token T_NAMESPACE
%token T_NS_C
%token T_DIR
%token T_NS_SEPARATOR
%token T_ELLIPSIS
%token T_NAME_FULLY_QUALIFIED
%token T_NAME_QUALIFIED
%token T_NAME_RELATIVE
%token T_ATTRIBUTE
%token T_ENUM

%%

start:
    top_statement_list                                      { $$ = $self->handleNamespaces($self->semStack[$1]); }
;

top_statement_list_ex:
      top_statement_list_ex top_statement                   { if ($self->semStack[$2] !== null) { $self->semStack[$1][] = $self->semStack[$2]; } $$ = $self->semStack[$1];; }
    | /* empty */                                           { $$ = array(); }
;

top_statement_list:
      top_statement_list_ex
          { $nop = $self->maybeCreateZeroLengthNop($self->tokenPos);;
            if ($nop !== null) { $self->semStack[$1][] = $nop; } $$ = $self->semStack[$1]; }
;

ampersand:
      T_AMPERSAND_FOLLOWED_BY_VAR_OR_VARARG
    | T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG
;

reserved_non_modifiers:
      T_INCLUDE | T_INCLUDE_ONCE | T_EVAL | T_REQUIRE | T_REQUIRE_ONCE | T_LOGICAL_OR | T_LOGICAL_XOR | T_LOGICAL_AND
    | T_INSTANCEOF | T_NEW | T_CLONE | T_EXIT | T_IF | T_ELSEIF | T_ELSE | T_ENDIF | T_DO | T_WHILE
    | T_ENDWHILE | T_FOR | T_ENDFOR | T_FOREACH | T_ENDFOREACH | T_DECLARE | T_ENDDECLARE | T_AS | T_TRY | T_CATCH
    | T_FINALLY | T_THROW | T_USE | T_INSTEADOF | T_GLOBAL | T_VAR | T_UNSET | T_ISSET | T_EMPTY | T_CONTINUE | T_GOTO
    | T_FUNCTION | T_CONST | T_RETURN | T_PRINT | T_YIELD | T_LIST | T_SWITCH | T_ENDSWITCH | T_CASE | T_DEFAULT
    | T_BREAK | T_ARRAY | T_CALLABLE | T_EXTENDS | T_IMPLEMENTS | T_NAMESPACE | T_TRAIT | T_INTERFACE | T_CLASS
    | T_CLASS_C | T_TRAIT_C | T_FUNC_C | T_METHOD_C | T_LINE | T_FILE | T_DIR | T_NS_C | T_FN
    | T_MATCH | T_ENUM
    | T_ECHO { $$ = $self->semStack[$1]; if ($$ === "<?=") $self->emitError(new Error('Cannot use "<?=" as an identifier', $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]))); }
;

semi_reserved:
      reserved_non_modifiers
    | T_STATIC | T_ABSTRACT | T_FINAL | T_PRIVATE | T_PROTECTED | T_PUBLIC | T_READONLY
;

identifier_maybe_reserved:
      T_STRING                                              { $$ = new Node\Identifier($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | semi_reserved                                         { $$ = new Node\Identifier($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

identifier_not_reserved:
      T_STRING                                              { $$ = new Node\Identifier($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

reserved_non_modifiers_identifier:
      reserved_non_modifiers                                { $$ = new Node\Identifier($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

namespace_declaration_name:
      T_STRING                                              { $$ = new Name($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | semi_reserved                                         { $$ = new Name($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_NAME_QUALIFIED                                      { $$ = new Name($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

namespace_name:
      T_STRING                                              { $$ = new Name($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_NAME_QUALIFIED                                      { $$ = new Name($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

legacy_namespace_name:
      namespace_name
    | T_NAME_FULLY_QUALIFIED                                { $$ = new Name(substr($self->semStack[$1], 1), $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

plain_variable:
      T_VARIABLE                                            { $$ = new Expr\Variable(substr($self->semStack[$1], 1), $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

semi:
      ';'                                                   { /* nothing */ }
    | error                                                 { /* nothing */ }
;

no_comma:
      /* empty */ { /* nothing */ }
    | ',' { $self->emitError(new Error('A trailing comma is not allowed here', $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]))); }
;

optional_comma:
      /* empty */
    | ','
;

attribute_decl:
      class_name                                            { $$ = new Node\Attribute($self->semStack[$1], [], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | class_name argument_list                              { $$ = new Node\Attribute($self->semStack[$1], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

attribute_group:
      attribute_decl                                        { $$ = array($self->semStack[$1]); }
    | attribute_group ',' attribute_decl                    { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

attribute:
      T_ATTRIBUTE attribute_group optional_comma ']'        { $$ = new Node\AttributeGroup($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

attributes:
      attribute                                             { $$ = array($self->semStack[$1]); }
    | attributes attribute                                  { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; }
;

optional_attributes:
      /* empty */                                           { $$ = []; }
    | attributes
;

top_statement:
      statement
    | function_declaration_statement
    | class_declaration_statement
    | T_HALT_COMPILER '(' ')' ';'
          { $$ = new Stmt\HaltCompiler($self->handleHaltCompiler(), $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_NAMESPACE namespace_declaration_name semi
          { $$ = new Stmt\Namespace_($self->semStack[$2], null, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $$->setAttribute('kind', Stmt\Namespace_::KIND_SEMICOLON);
            $self->checkNamespace($$); }
    | T_NAMESPACE namespace_declaration_name '{' top_statement_list '}'
          { $$ = new Stmt\Namespace_($self->semStack[$2], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $$->setAttribute('kind', Stmt\Namespace_::KIND_BRACED);
            $self->checkNamespace($$); }
    | T_NAMESPACE '{' top_statement_list '}'
          { $$ = new Stmt\Namespace_(null, $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $$->setAttribute('kind', Stmt\Namespace_::KIND_BRACED);
            $self->checkNamespace($$); }
    | T_USE use_declarations semi                           { $$ = new Stmt\Use_($self->semStack[$2], Stmt\Use_::TYPE_NORMAL, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_USE use_type use_declarations semi                  { $$ = new Stmt\Use_($self->semStack[$3], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | group_use_declaration
    | T_CONST constant_declaration_list semi                { $$ = new Stmt\Const_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

use_type:
      T_FUNCTION                                            { $$ = Stmt\Use_::TYPE_FUNCTION; }
    | T_CONST                                               { $$ = Stmt\Use_::TYPE_CONSTANT; }
;

group_use_declaration:
      T_USE use_type legacy_namespace_name T_NS_SEPARATOR '{' unprefixed_use_declarations '}' semi
          { $$ = new Stmt\GroupUse($self->semStack[$3], $self->semStack[$6], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_USE legacy_namespace_name T_NS_SEPARATOR '{' inline_use_declarations '}' semi
          { $$ = new Stmt\GroupUse($self->semStack[$2], $self->semStack[$5], Stmt\Use_::TYPE_UNKNOWN, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

unprefixed_use_declarations:
      non_empty_unprefixed_use_declarations optional_comma
;

non_empty_unprefixed_use_declarations:
      non_empty_unprefixed_use_declarations ',' unprefixed_use_declaration
          { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
    | unprefixed_use_declaration                            { $$ = array($self->semStack[$1]); }
;

use_declarations:
      non_empty_use_declarations no_comma
;

non_empty_use_declarations:
      non_empty_use_declarations ',' use_declaration        { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
    | use_declaration                                       { $$ = array($self->semStack[$1]); }
;

inline_use_declarations:
      non_empty_inline_use_declarations optional_comma
;

non_empty_inline_use_declarations:
      non_empty_inline_use_declarations ',' inline_use_declaration
          { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
    | inline_use_declaration                                { $$ = array($self->semStack[$1]); }
;

unprefixed_use_declaration:
      namespace_name
          { $$ = new Node\UseItem($self->semStack[$1], null, Stmt\Use_::TYPE_UNKNOWN, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->checkUseUse($$, $1); }
    | namespace_name T_AS identifier_not_reserved
          { $$ = new Node\UseItem($self->semStack[$1], $self->semStack[$3], Stmt\Use_::TYPE_UNKNOWN, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->checkUseUse($$, $3); }
;

use_declaration:
      legacy_namespace_name
          { $$ = new Node\UseItem($self->semStack[$1], null, Stmt\Use_::TYPE_UNKNOWN, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->checkUseUse($$, $1); }
    | legacy_namespace_name T_AS identifier_not_reserved
          { $$ = new Node\UseItem($self->semStack[$1], $self->semStack[$3], Stmt\Use_::TYPE_UNKNOWN, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->checkUseUse($$, $3); }
;

inline_use_declaration:
      unprefixed_use_declaration                            { $$ = $self->semStack[$1]; $$->type = Stmt\Use_::TYPE_NORMAL; }
    | use_type unprefixed_use_declaration                   { $$ = $self->semStack[$2]; $$->type = $self->semStack[$1]; }
;

constant_declaration_list:
      non_empty_constant_declaration_list no_comma
;

non_empty_constant_declaration_list:
      non_empty_constant_declaration_list ',' constant_declaration
          { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
    | constant_declaration                                  { $$ = array($self->semStack[$1]); }
;

constant_declaration:
    identifier_not_reserved '=' expr                        { $$ = new Node\Const_($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

class_const_list:
      non_empty_class_const_list no_comma
;

non_empty_class_const_list:
      non_empty_class_const_list ',' class_const            { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
    | class_const                                           { $$ = array($self->semStack[$1]); }
;

class_const:
      T_STRING '=' expr
          { $$ = new Node\Const_(new Node\Identifier($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1],  $self->tokenEndStack[$1])), $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | semi_reserved '=' expr
          { $$ = new Node\Const_(new Node\Identifier($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1],  $self->tokenEndStack[$1])), $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

inner_statement_list_ex:
      inner_statement_list_ex inner_statement               { if ($self->semStack[$2] !== null) { $self->semStack[$1][] = $self->semStack[$2]; } $$ = $self->semStack[$1];; }
    | /* empty */                                           { $$ = array(); }
;

inner_statement_list:
      inner_statement_list_ex
          { $nop = $self->maybeCreateZeroLengthNop($self->tokenPos);;
            if ($nop !== null) { $self->semStack[$1][] = $nop; } $$ = $self->semStack[$1]; }
;

inner_statement:
      statement
    | function_declaration_statement
    | class_declaration_statement
    | T_HALT_COMPILER
          { throw new Error('__HALT_COMPILER() can only be used from the outermost scope', $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

non_empty_statement:
      '{' inner_statement_list '}'                          { $$ = new Stmt\Block($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_IF '(' expr ')' blocklike_statement elseif_list else_single
          { $$ = new Stmt\If_($self->semStack[$3], ['stmts' => $self->semStack[$5], 'elseifs' => $self->semStack[$6], 'else' => $self->semStack[$7]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_IF '(' expr ')' ':' inner_statement_list new_elseif_list new_else_single T_ENDIF ';'
          { $$ = new Stmt\If_($self->semStack[$3], ['stmts' => $self->semStack[$6], 'elseifs' => $self->semStack[$7], 'else' => $self->semStack[$8]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_WHILE '(' expr ')' while_statement                  { $$ = new Stmt\While_($self->semStack[$3], $self->semStack[$5], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DO blocklike_statement T_WHILE '(' expr ')' ';'     { $$ = new Stmt\Do_($self->semStack[$5], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_FOR '(' for_expr ';'  for_expr ';' for_expr ')' for_statement
          { $$ = new Stmt\For_(['init' => $self->semStack[$3], 'cond' => $self->semStack[$5], 'loop' => $self->semStack[$7], 'stmts' => $self->semStack[$9]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_SWITCH '(' expr ')' switch_case_list                { $$ = new Stmt\Switch_($self->semStack[$3], $self->semStack[$5], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_BREAK optional_expr semi                            { $$ = new Stmt\Break_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_CONTINUE optional_expr semi                         { $$ = new Stmt\Continue_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_RETURN optional_expr semi                           { $$ = new Stmt\Return_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_GLOBAL global_var_list semi                         { $$ = new Stmt\Global_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_STATIC static_var_list semi                         { $$ = new Stmt\Static_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_ECHO expr_list_forbid_comma semi                    { $$ = new Stmt\Echo_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_INLINE_HTML {
        $$ = new Stmt\InlineHTML($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
        $$->setAttribute('hasLeadingNewline', $self->inlineHtmlHasLeadingNewline($1));
    }
    | expr semi                                             { $$ = new Stmt\Expression($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_UNSET '(' variables_list ')' semi                   { $$ = new Stmt\Unset_($self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_FOREACH '(' expr T_AS foreach_variable ')' foreach_statement
          { $$ = new Stmt\Foreach_($self->semStack[$3], $self->semStack[$5][0], ['keyVar' => null, 'byRef' => $self->semStack[$5][1], 'stmts' => $self->semStack[$7]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_FOREACH '(' expr T_AS variable T_DOUBLE_ARROW foreach_variable ')' foreach_statement
          { $$ = new Stmt\Foreach_($self->semStack[$3], $self->semStack[$7][0], ['keyVar' => $self->semStack[$5], 'byRef' => $self->semStack[$7][1], 'stmts' => $self->semStack[$9]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_FOREACH '(' expr error ')' foreach_statement
          { $$ = new Stmt\Foreach_($self->semStack[$3], new Expr\Error($self->getAttributes($self->tokenStartStack[$4],  $self->tokenEndStack[$4])), ['stmts' => $self->semStack[$6]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DECLARE '(' declare_list ')' declare_statement      { $$ = new Stmt\Declare_($self->semStack[$3], $self->semStack[$5], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_TRY '{' inner_statement_list '}' catches optional_finally
          { $$ = new Stmt\TryCatch($self->semStack[$3], $self->semStack[$5], $self->semStack[$6], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->checkTryCatch($$); }
    | T_GOTO identifier_not_reserved semi                   { $$ = new Stmt\Goto_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | identifier_not_reserved ':'                           { $$ = new Stmt\Label($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | error                                                 { $$ = null; /* means: no statement */ }
;

statement:
      non_empty_statement
    | ';'                                                   { $$ = $self->maybeCreateNop($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]); }
;

blocklike_statement:
     statement                                              { if ($self->semStack[$1] instanceof Stmt\Block) { $$ = $self->semStack[$1]->stmts; } else if ($self->semStack[$1] === null) { $$ = []; } else { $$ = [$self->semStack[$1]]; }; }
;

catches:
      /* empty */                                           { $$ = array(); }
    | catches catch                                         { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; }
;

name_union:
      name                                                  { $$ = array($self->semStack[$1]); }
    | name_union '|' name                                   { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

catch:
    T_CATCH '(' name_union optional_plain_variable ')' '{' inner_statement_list '}'
        { $$ = new Stmt\Catch_($self->semStack[$3], $self->semStack[$4], $self->semStack[$7], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

optional_finally:
      /* empty */                                           { $$ = null; }
    | T_FINALLY '{' inner_statement_list '}'                { $$ = new Stmt\Finally_($self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

variables_list:
      non_empty_variables_list optional_comma
;

non_empty_variables_list:
      variable                                              { $$ = array($self->semStack[$1]); }
    | non_empty_variables_list ',' variable                 { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

optional_ref:
      /* empty */                                           { $$ = false; }
    | ampersand                                             { $$ = true; }
;

optional_arg_ref:
      /* empty */                                           { $$ = false; }
    | T_AMPERSAND_FOLLOWED_BY_VAR_OR_VARARG                 { $$ = true; }
;

optional_ellipsis:
      /* empty */                                           { $$ = false; }
    | T_ELLIPSIS                                            { $$ = true; }
;

block_or_error:
      '{' inner_statement_list '}'                          { $$ = $self->semStack[$2]; }
    | error                                                 { $$ = []; }
;

fn_identifier:
      identifier_not_reserved
    | T_READONLY                                            { $$ = new Node\Identifier($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_EXIT                                                { $$ = new Node\Identifier($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

function_declaration_statement:
      T_FUNCTION optional_ref fn_identifier '(' parameter_list ')' optional_return_type block_or_error
          { $$ = new Stmt\Function_($self->semStack[$3], ['byRef' => $self->semStack[$2], 'params' => $self->semStack[$5], 'returnType' => $self->semStack[$7], 'stmts' => $self->semStack[$8], 'attrGroups' => []], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | attributes T_FUNCTION optional_ref fn_identifier '(' parameter_list ')' optional_return_type block_or_error
          { $$ = new Stmt\Function_($self->semStack[$4], ['byRef' => $self->semStack[$3], 'params' => $self->semStack[$6], 'returnType' => $self->semStack[$8], 'stmts' => $self->semStack[$9], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

class_declaration_statement:
      class_entry_type identifier_not_reserved extends_from implements_list '{' class_statement_list '}'
          { $$ = new Stmt\Class_($self->semStack[$2], ['type' => $self->semStack[$1], 'extends' => $self->semStack[$3], 'implements' => $self->semStack[$4], 'stmts' => $self->semStack[$6], 'attrGroups' => []], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $self->checkClass($$, $2); }
    | attributes class_entry_type identifier_not_reserved extends_from implements_list '{' class_statement_list '}'
          { $$ = new Stmt\Class_($self->semStack[$3], ['type' => $self->semStack[$2], 'extends' => $self->semStack[$4], 'implements' => $self->semStack[$5], 'stmts' => $self->semStack[$7], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $self->checkClass($$, $3); }
    | optional_attributes T_INTERFACE identifier_not_reserved interface_extends_list '{' class_statement_list '}'
          { $$ = new Stmt\Interface_($self->semStack[$3], ['extends' => $self->semStack[$4], 'stmts' => $self->semStack[$6], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $self->checkInterface($$, $3); }
    | optional_attributes T_TRAIT identifier_not_reserved '{' class_statement_list '}'
          { $$ = new Stmt\Trait_($self->semStack[$3], ['stmts' => $self->semStack[$5], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | optional_attributes T_ENUM identifier_not_reserved enum_scalar_type implements_list '{' class_statement_list '}'
          { $$ = new Stmt\Enum_($self->semStack[$3], ['scalarType' => $self->semStack[$4], 'implements' => $self->semStack[$5], 'stmts' => $self->semStack[$7], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $self->checkEnum($$, $3); }
;

enum_scalar_type:
      /* empty */                                           { $$ = null; }
    | ':' type                                              { $$ = $self->semStack[$2]; }

enum_case_expr:
      /* empty */                                           { $$ = null; }
    | '=' expr                                              { $$ = $self->semStack[$2]; }
;

class_entry_type:
      T_CLASS                                               { $$ = 0; }
    | class_modifiers T_CLASS
;

class_modifiers:
      class_modifier
    | class_modifiers class_modifier                        { $self->checkClassModifier($self->semStack[$1], $self->semStack[$2], $2); $$ = $self->semStack[$1] | $self->semStack[$2]; }
;

class_modifier:
      T_ABSTRACT                                            { $$ = Modifiers::ABSTRACT; }
    | T_FINAL                                               { $$ = Modifiers::FINAL; }
    | T_READONLY                                            { $$ = Modifiers::READONLY; }
;

extends_from:
      /* empty */                                           { $$ = null; }
    | T_EXTENDS class_name                                  { $$ = $self->semStack[$2]; }
;

interface_extends_list:
      /* empty */                                           { $$ = array(); }
    | T_EXTENDS class_name_list                             { $$ = $self->semStack[$2]; }
;

implements_list:
      /* empty */                                           { $$ = array(); }
    | T_IMPLEMENTS class_name_list                          { $$ = $self->semStack[$2]; }
;

class_name_list:
      non_empty_class_name_list no_comma
;

non_empty_class_name_list:
      class_name                                            { $$ = array($self->semStack[$1]); }
    | non_empty_class_name_list ',' class_name              { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

for_statement:
      blocklike_statement
    | ':' inner_statement_list T_ENDFOR ';'                 { $$ = $self->semStack[$2]; }
;

foreach_statement:
      blocklike_statement
    | ':' inner_statement_list T_ENDFOREACH ';'             { $$ = $self->semStack[$2]; }
;

declare_statement:
      non_empty_statement                                   { if ($self->semStack[$1] instanceof Stmt\Block) { $$ = $self->semStack[$1]->stmts; } else if ($self->semStack[$1] === null) { $$ = []; } else { $$ = [$self->semStack[$1]]; }; }
    | ';'                                                   { $$ = null; }
    | ':' inner_statement_list T_ENDDECLARE ';'             { $$ = $self->semStack[$2]; }
;

declare_list:
      non_empty_declare_list no_comma
;

non_empty_declare_list:
      declare_list_element                                  { $$ = array($self->semStack[$1]); }
    | non_empty_declare_list ',' declare_list_element       { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

declare_list_element:
      identifier_not_reserved '=' expr                      { $$ = new Node\DeclareItem($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

switch_case_list:
      '{' case_list '}'                                     { $$ = $self->semStack[$2]; }
    | '{' ';' case_list '}'                                 { $$ = $self->semStack[$3]; }
    | ':' case_list T_ENDSWITCH ';'                         { $$ = $self->semStack[$2]; }
    | ':' ';' case_list T_ENDSWITCH ';'                     { $$ = $self->semStack[$3]; }
;

case_list:
      /* empty */                                           { $$ = array(); }
    | case_list case                                        { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; }
;

case:
      T_CASE expr case_separator inner_statement_list_ex    { $$ = new Stmt\Case_($self->semStack[$2], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DEFAULT case_separator inner_statement_list_ex      { $$ = new Stmt\Case_(null, $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

case_separator:
      ':'
    | ';'
;

match:
      T_MATCH '(' expr ')' '{' match_arm_list '}'           { $$ = new Expr\Match_($self->semStack[$3], $self->semStack[$6], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

match_arm_list:
      /* empty */                                           { $$ = []; }
    | non_empty_match_arm_list optional_comma
;

non_empty_match_arm_list:
      match_arm                                             { $$ = array($self->semStack[$1]); }
    | non_empty_match_arm_list ',' match_arm                { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

match_arm:
      expr_list_allow_comma T_DOUBLE_ARROW expr             { $$ = new Node\MatchArm($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DEFAULT optional_comma T_DOUBLE_ARROW expr          { $$ = new Node\MatchArm(null, $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

while_statement:
      blocklike_statement                                   { $$ = $self->semStack[$1]; }
    | ':' inner_statement_list T_ENDWHILE ';'               { $$ = $self->semStack[$2]; }
;

elseif_list:
      /* empty */                                           { $$ = array(); }
    | elseif_list elseif                                    { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; }
;

elseif:
      T_ELSEIF '(' expr ')' blocklike_statement             { $$ = new Stmt\ElseIf_($self->semStack[$3], $self->semStack[$5], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

new_elseif_list:
      /* empty */                                           { $$ = array(); }
    | new_elseif_list new_elseif                            { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; }
;

new_elseif:
     T_ELSEIF '(' expr ')' ':' inner_statement_list
         { $$ = new Stmt\ElseIf_($self->semStack[$3], $self->semStack[$6], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->fixupAlternativeElse($$); }
;

else_single:
      /* empty */                                           { $$ = null; }
    | T_ELSE blocklike_statement                            { $$ = new Stmt\Else_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

new_else_single:
      /* empty */                                           { $$ = null; }
    | T_ELSE ':' inner_statement_list
          { $$ = new Stmt\Else_($self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->fixupAlternativeElse($$); }
;

foreach_variable:
      variable                                              { $$ = array($self->semStack[$1], false); }
    | ampersand variable                                    { $$ = array($self->semStack[$2], true); }
    | list_expr                                             { $$ = array($self->semStack[$1], false); }
    | array_short_syntax
          { $$ = array($self->fixupArrayDestructuring($self->semStack[$1]), false); }
;

parameter_list:
      non_empty_parameter_list optional_comma
    | /* empty */                                           { $$ = array(); }
;

non_empty_parameter_list:
      parameter                                             { $$ = array($self->semStack[$1]); }
    | non_empty_parameter_list ',' parameter                { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

optional_property_modifiers:
      /* empty */               { $$ = 0; }
    | optional_property_modifiers property_modifier
          { $self->checkModifier($self->semStack[$1], $self->semStack[$2], $2); $$ = $self->semStack[$1] | $self->semStack[$2]; }
;

property_modifier:
      T_PUBLIC                  { $$ = Modifiers::PUBLIC; }
    | T_PROTECTED               { $$ = Modifiers::PROTECTED; }
    | T_PRIVATE                 { $$ = Modifiers::PRIVATE; }
    | T_PUBLIC_SET              { $$ = Modifiers::PUBLIC_SET; }
    | T_PROTECTED_SET           { $$ = Modifiers::PROTECTED_SET; }
    | T_PRIVATE_SET             { $$ = Modifiers::PRIVATE_SET; }
    | T_READONLY                { $$ = Modifiers::READONLY; }
;

parameter:
      optional_attributes optional_property_modifiers optional_type_without_static
      optional_arg_ref optional_ellipsis plain_variable optional_property_hook_list
          { $$ = new Node\Param($self->semStack[$6], null, $self->semStack[$3], $self->semStack[$4], $self->semStack[$5], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->semStack[$2], $self->semStack[$1], $self->semStack[$7]);
            $self->checkParam($$); }
    | optional_attributes optional_property_modifiers optional_type_without_static
      optional_arg_ref optional_ellipsis plain_variable '=' expr optional_property_hook_list
          { $$ = new Node\Param($self->semStack[$6], $self->semStack[$8], $self->semStack[$3], $self->semStack[$4], $self->semStack[$5], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->semStack[$2], $self->semStack[$1], $self->semStack[$9]);
            $self->checkParam($$); }
    | optional_attributes optional_property_modifiers optional_type_without_static
      optional_arg_ref optional_ellipsis error
          { $$ = new Node\Param(new Expr\Error($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])), null, $self->semStack[$3], $self->semStack[$4], $self->semStack[$5], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->semStack[$2], $self->semStack[$1]); }
;

type_expr:
      type
    | '?' type                                              { $$ = new Node\NullableType($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | union_type                                            { $$ = new Node\UnionType($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | intersection_type
;

type:
      type_without_static
    | T_STATIC                                              { $$ = new Node\Name('static', $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

type_without_static:
      name                                                  { $$ = $self->handleBuiltinTypes($self->semStack[$1]); }
    | T_ARRAY                                               { $$ = new Node\Identifier('array', $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_CALLABLE                                            { $$ = new Node\Identifier('callable', $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

union_type_element:
      type
    | '(' intersection_type ')' { $$ = $self->semStack[$2]; }
;

union_type:
      union_type_element '|' union_type_element             { $$ = array($self->semStack[$1], $self->semStack[$3]); }
    | union_type '|' union_type_element                     { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

union_type_without_static_element:
                type_without_static
        |        '(' intersection_type_without_static ')' { $$ = $self->semStack[$2]; }
;

union_type_without_static:
      union_type_without_static_element '|' union_type_without_static_element   { $$ = array($self->semStack[$1], $self->semStack[$3]); }
    | union_type_without_static '|' union_type_without_static_element           { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

intersection_type_list:
      type T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG type   { $$ = array($self->semStack[$1], $self->semStack[$3]); }
    | intersection_type_list T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG type
          { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

intersection_type:
      intersection_type_list { $$ = new Node\IntersectionType($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

intersection_type_without_static_list:
      type_without_static T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG type_without_static
          { $$ = array($self->semStack[$1], $self->semStack[$3]); }
    | intersection_type_without_static_list T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG type_without_static
          { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

intersection_type_without_static:
      intersection_type_without_static_list { $$ = new Node\IntersectionType($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

type_expr_without_static:
      type_without_static
    | '?' type_without_static                               { $$ = new Node\NullableType($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | union_type_without_static                             { $$ = new Node\UnionType($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | intersection_type_without_static
;

optional_type_without_static:
      /* empty */                                           { $$ = null; }
    | type_expr_without_static
;

optional_return_type:
      /* empty */                                           { $$ = null; }
    | ':' type_expr                                         { $$ = $self->semStack[$2]; }
    | ':' error                                             { $$ = null; }
;

argument_list:
      '(' ')'                                               { $$ = array(); }
    | '(' non_empty_argument_list optional_comma ')'        { $$ = $self->semStack[$2]; }
    | '(' variadic_placeholder ')'                          { $$ = array($self->semStack[$2]); }
;

variadic_placeholder:
      T_ELLIPSIS                                            { $$ = new Node\VariadicPlaceholder($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

non_empty_argument_list:
      argument                                              { $$ = array($self->semStack[$1]); }
    | non_empty_argument_list ',' argument                  { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

argument:
      expr                                                  { $$ = new Node\Arg($self->semStack[$1], false, false, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | ampersand variable                                    { $$ = new Node\Arg($self->semStack[$2], true, false, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_ELLIPSIS expr                                       { $$ = new Node\Arg($self->semStack[$2], false, true, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | identifier_maybe_reserved ':' expr
          { $$ = new Node\Arg($self->semStack[$3], false, false, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->semStack[$1]); }
;

global_var_list:
      non_empty_global_var_list no_comma
;

non_empty_global_var_list:
      non_empty_global_var_list ',' global_var              { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
    | global_var                                            { $$ = array($self->semStack[$1]); }
;

global_var:
      simple_variable
;

static_var_list:
      non_empty_static_var_list no_comma
;

non_empty_static_var_list:
      non_empty_static_var_list ',' static_var              { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
    | static_var                                            { $$ = array($self->semStack[$1]); }
;

static_var:
      plain_variable                                        { $$ = new Node\StaticVar($self->semStack[$1], null, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | plain_variable '=' expr                               { $$ = new Node\StaticVar($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

class_statement_list_ex:
      class_statement_list_ex class_statement               { if ($self->semStack[$2] !== null) { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; } else { $$ = $self->semStack[$1]; } }
    | /* empty */                                           { $$ = array(); }
;

class_statement_list:
      class_statement_list_ex
          { $nop = $self->maybeCreateZeroLengthNop($self->tokenPos);;
            if ($nop !== null) { $self->semStack[$1][] = $nop; } $$ = $self->semStack[$1]; }
;

class_statement:
      optional_attributes variable_modifiers optional_type_without_static property_declaration_list semi
          { $$ = new Stmt\Property($self->semStack[$2], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->semStack[$3], $self->semStack[$1]); }    | optional_attributes variable_modifiers optional_type_without_static property_declaration_list '{' property_hook_list '}'
          { $$ = new Stmt\Property($self->semStack[$2], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->semStack[$3], $self->semStack[$1], $self->semStack[$6]);
            $self->checkPropertyHookList($self->semStack[$6], $5); }
    | optional_attributes method_modifiers T_CONST class_const_list semi
          { $$ = new Stmt\ClassConst($self->semStack[$4], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->semStack[$1]);
            $self->checkClassConst($$, $2); }
    | optional_attributes method_modifiers T_CONST type_expr class_const_list semi
          { $$ = new Stmt\ClassConst($self->semStack[$5], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->semStack[$1], $self->semStack[$4]);
            $self->checkClassConst($$, $2); }
    | optional_attributes method_modifiers T_FUNCTION optional_ref identifier_maybe_reserved '(' parameter_list ')'
      optional_return_type method_body
          { $$ = new Stmt\ClassMethod($self->semStack[$5], ['type' => $self->semStack[$2], 'byRef' => $self->semStack[$4], 'params' => $self->semStack[$7], 'returnType' => $self->semStack[$9], 'stmts' => $self->semStack[$10], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $self->checkClassMethod($$, $2); }
    | T_USE class_name_list trait_adaptations               { $$ = new Stmt\TraitUse($self->semStack[$2], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | optional_attributes T_CASE identifier_maybe_reserved enum_case_expr semi
         { $$ = new Stmt\EnumCase($self->semStack[$3], $self->semStack[$4], $self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | error                                                 { $$ = null; /* will be skipped */ }
;

trait_adaptations:
      ';'                                                   { $$ = array(); }
    | '{' trait_adaptation_list '}'                         { $$ = $self->semStack[$2]; }
;

trait_adaptation_list:
      /* empty */                                           { $$ = array(); }
    | trait_adaptation_list trait_adaptation                { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; }
;

trait_adaptation:
      trait_method_reference_fully_qualified T_INSTEADOF class_name_list ';'
          { $$ = new Stmt\TraitUseAdaptation\Precedence($self->semStack[$1][0], $self->semStack[$1][1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | trait_method_reference T_AS member_modifier identifier_maybe_reserved ';'
          { $$ = new Stmt\TraitUseAdaptation\Alias($self->semStack[$1][0], $self->semStack[$1][1], $self->semStack[$3], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | trait_method_reference T_AS member_modifier ';'
          { $$ = new Stmt\TraitUseAdaptation\Alias($self->semStack[$1][0], $self->semStack[$1][1], $self->semStack[$3], null, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | trait_method_reference T_AS identifier_not_reserved ';'
          { $$ = new Stmt\TraitUseAdaptation\Alias($self->semStack[$1][0], $self->semStack[$1][1], null, $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | trait_method_reference T_AS reserved_non_modifiers_identifier ';'
          { $$ = new Stmt\TraitUseAdaptation\Alias($self->semStack[$1][0], $self->semStack[$1][1], null, $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

trait_method_reference_fully_qualified:
      name T_PAAMAYIM_NEKUDOTAYIM identifier_maybe_reserved { $$ = array($self->semStack[$1], $self->semStack[$3]); }
;
trait_method_reference:
      trait_method_reference_fully_qualified
    | identifier_maybe_reserved                             { $$ = array(null, $self->semStack[$1]); }
;

method_body:
      ';' /* abstract method */                             { $$ = null; }
    | block_or_error
;

variable_modifiers:
      non_empty_member_modifiers
    | T_VAR                                                 { $$ = 0; }
;

method_modifiers:
      /* empty */                                           { $$ = 0; }
    | non_empty_member_modifiers
;

non_empty_member_modifiers:
      member_modifier
    | non_empty_member_modifiers member_modifier            { $self->checkModifier($self->semStack[$1], $self->semStack[$2], $2); $$ = $self->semStack[$1] | $self->semStack[$2]; }
;

member_modifier:
      T_PUBLIC                                              { $$ = Modifiers::PUBLIC; }
    | T_PROTECTED                                           { $$ = Modifiers::PROTECTED; }
    | T_PRIVATE                                             { $$ = Modifiers::PRIVATE; }
    | T_PUBLIC_SET                                          { $$ = Modifiers::PUBLIC_SET; }
    | T_PROTECTED_SET                                       { $$ = Modifiers::PROTECTED_SET; }
    | T_PRIVATE_SET                                         { $$ = Modifiers::PRIVATE_SET; }
    | T_STATIC                                              { $$ = Modifiers::STATIC; }
    | T_ABSTRACT                                            { $$ = Modifiers::ABSTRACT; }
    | T_FINAL                                               { $$ = Modifiers::FINAL; }
    | T_READONLY                                            { $$ = Modifiers::READONLY; }
;

property_declaration_list:
      non_empty_property_declaration_list no_comma
;

non_empty_property_declaration_list:
      property_declaration                                  { $$ = array($self->semStack[$1]); }
    | non_empty_property_declaration_list ',' property_declaration
          { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

property_decl_name:
      T_VARIABLE                                            { $$ = new Node\VarLikeIdentifier(substr($self->semStack[$1], 1), $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

property_declaration:
      property_decl_name                                    { $$ = new Node\PropertyItem($self->semStack[$1], null, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | property_decl_name '=' expr                           { $$ = new Node\PropertyItem($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

property_hook_list:
      /* empty */                                           { $$ = []; }
    | property_hook_list property_hook                      { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; }
;

optional_property_hook_list:
      /* empty */                                           { $$ = []; }    | '{' property_hook_list '}'                            { $$ = $self->semStack[$2]; $self->checkPropertyHookList($self->semStack[$2], $1); }
;

property_hook:
      optional_attributes property_hook_modifiers optional_ref identifier_not_reserved property_hook_body
          { $$ = new Node\PropertyHook($self->semStack[$4], $self->semStack[$5], ['flags' => $self->semStack[$2], 'byRef' => $self->semStack[$3], 'params' => [], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $self->checkPropertyHook($$, null); }
    | optional_attributes property_hook_modifiers optional_ref identifier_not_reserved '(' parameter_list ')' property_hook_body
          { $$ = new Node\PropertyHook($self->semStack[$4], $self->semStack[$8], ['flags' => $self->semStack[$2], 'byRef' => $self->semStack[$3], 'params' => $self->semStack[$6], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            $self->checkPropertyHook($$, $5); }
;

property_hook_body:
      ';'                                                   { $$ = null; }
    | '{' inner_statement_list '}'                          { $$ = $self->semStack[$2]; }
    | T_DOUBLE_ARROW expr ';'                               { $$ = $self->semStack[$2]; }
;

property_hook_modifiers:
      /* empty */                                           { $$ = 0; }
    | property_hook_modifiers member_modifier
          { $self->checkPropertyHookModifiers($self->semStack[$1], $self->semStack[$2], $2); $$ = $self->semStack[$1] | $self->semStack[$2]; }
;

expr_list_forbid_comma:
      non_empty_expr_list no_comma
;

expr_list_allow_comma:
      non_empty_expr_list optional_comma
;

non_empty_expr_list:
      non_empty_expr_list ',' expr                          { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
    | expr                                                  { $$ = array($self->semStack[$1]); }
;

for_expr:
      /* empty */                                           { $$ = array(); }
    | expr_list_forbid_comma
;

expr:
      variable
    | list_expr '=' expr                                    { $$ = new Expr\Assign($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | array_short_syntax '=' expr
          { $$ = new Expr\Assign($self->fixupArrayDestructuring($self->semStack[$1]), $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable '=' expr                                     { $$ = new Expr\Assign($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable '=' ampersand variable                       { $$ = new Expr\AssignRef($self->semStack[$1], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable '=' ampersand new_expr
          { $$ = new Expr\AssignRef($self->semStack[$1], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]));
            if (!$self->phpVersion->allowsAssignNewByReference()) {
                $self->emitError(new Error('Cannot assign new by reference', $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])));
            }
          }
    | new_expr
    | match
    | T_CLONE expr                                          { $$ = new Expr\Clone_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_PLUS_EQUAL expr                            { $$ = new Expr\AssignOp\Plus($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_MINUS_EQUAL expr                           { $$ = new Expr\AssignOp\Minus($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_MUL_EQUAL expr                             { $$ = new Expr\AssignOp\Mul($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_DIV_EQUAL expr                             { $$ = new Expr\AssignOp\Div($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_CONCAT_EQUAL expr                          { $$ = new Expr\AssignOp\Concat($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_MOD_EQUAL expr                             { $$ = new Expr\AssignOp\Mod($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_AND_EQUAL expr                             { $$ = new Expr\AssignOp\BitwiseAnd($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_OR_EQUAL expr                              { $$ = new Expr\AssignOp\BitwiseOr($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_XOR_EQUAL expr                             { $$ = new Expr\AssignOp\BitwiseXor($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_SL_EQUAL expr                              { $$ = new Expr\AssignOp\ShiftLeft($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_SR_EQUAL expr                              { $$ = new Expr\AssignOp\ShiftRight($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_POW_EQUAL expr                             { $$ = new Expr\AssignOp\Pow($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_COALESCE_EQUAL expr                        { $$ = new Expr\AssignOp\Coalesce($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_INC                                        { $$ = new Expr\PostInc($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_INC variable                                        { $$ = new Expr\PreInc($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | variable T_DEC                                        { $$ = new Expr\PostDec($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DEC variable                                        { $$ = new Expr\PreDec($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_BOOLEAN_OR expr                                { $$ = new Expr\BinaryOp\BooleanOr($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_BOOLEAN_AND expr                               { $$ = new Expr\BinaryOp\BooleanAnd($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_LOGICAL_OR expr                                { $$ = new Expr\BinaryOp\LogicalOr($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_LOGICAL_AND expr                               { $$ = new Expr\BinaryOp\LogicalAnd($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_LOGICAL_XOR expr                               { $$ = new Expr\BinaryOp\LogicalXor($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '|' expr                                         { $$ = new Expr\BinaryOp\BitwiseOr($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_AMPERSAND_NOT_FOLLOWED_BY_VAR_OR_VARARG expr   { $$ = new Expr\BinaryOp\BitwiseAnd($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_AMPERSAND_FOLLOWED_BY_VAR_OR_VARARG expr       { $$ = new Expr\BinaryOp\BitwiseAnd($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '^' expr                                         { $$ = new Expr\BinaryOp\BitwiseXor($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '.' expr                                         { $$ = new Expr\BinaryOp\Concat($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '+' expr                                         { $$ = new Expr\BinaryOp\Plus($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '-' expr                                         { $$ = new Expr\BinaryOp\Minus($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '*' expr                                         { $$ = new Expr\BinaryOp\Mul($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '/' expr                                         { $$ = new Expr\BinaryOp\Div($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '%' expr                                         { $$ = new Expr\BinaryOp\Mod($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_SL expr                                        { $$ = new Expr\BinaryOp\ShiftLeft($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_SR expr                                        { $$ = new Expr\BinaryOp\ShiftRight($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_POW expr                                       { $$ = new Expr\BinaryOp\Pow($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | '+' expr %prec T_INC                                  { $$ = new Expr\UnaryPlus($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | '-' expr %prec T_INC                                  { $$ = new Expr\UnaryMinus($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | '!' expr                                              { $$ = new Expr\BooleanNot($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | '~' expr                                              { $$ = new Expr\BitwiseNot($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_IS_IDENTICAL expr                              { $$ = new Expr\BinaryOp\Identical($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_IS_NOT_IDENTICAL expr                          { $$ = new Expr\BinaryOp\NotIdentical($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_IS_EQUAL expr                                  { $$ = new Expr\BinaryOp\Equal($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_IS_NOT_EQUAL expr                              { $$ = new Expr\BinaryOp\NotEqual($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_SPACESHIP expr                                 { $$ = new Expr\BinaryOp\Spaceship($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '<' expr                                         { $$ = new Expr\BinaryOp\Smaller($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_IS_SMALLER_OR_EQUAL expr                       { $$ = new Expr\BinaryOp\SmallerOrEqual($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '>' expr                                         { $$ = new Expr\BinaryOp\Greater($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_IS_GREATER_OR_EQUAL expr                       { $$ = new Expr\BinaryOp\GreaterOrEqual($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_INSTANCEOF class_name_reference                { $$ = new Expr\Instanceof_($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | '(' expr ')'                                          { $$ = $self->semStack[$2]; }
    | expr '?' expr ':' expr                                { $$ = new Expr\Ternary($self->semStack[$1], $self->semStack[$3], $self->semStack[$5], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr '?' ':' expr                                     { $$ = new Expr\Ternary($self->semStack[$1], null, $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_COALESCE expr                                  { $$ = new Expr\BinaryOp\Coalesce($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_ISSET '(' expr_list_allow_comma ')'                 { $$ = new Expr\Isset_($self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_EMPTY '(' expr ')'                                  { $$ = new Expr\Empty_($self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_INCLUDE expr                                        { $$ = new Expr\Include_($self->semStack[$2], Expr\Include_::TYPE_INCLUDE, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_INCLUDE_ONCE expr                                   { $$ = new Expr\Include_($self->semStack[$2], Expr\Include_::TYPE_INCLUDE_ONCE, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_EVAL '(' expr ')'                                   { $$ = new Expr\Eval_($self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_REQUIRE expr                                        { $$ = new Expr\Include_($self->semStack[$2], Expr\Include_::TYPE_REQUIRE, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_REQUIRE_ONCE expr                                   { $$ = new Expr\Include_($self->semStack[$2], Expr\Include_::TYPE_REQUIRE_ONCE, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_INT_CAST expr                                       { $$ = new Expr\Cast\Int_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DOUBLE_CAST expr
          { $attrs = $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]);
            $attrs['kind'] = $self->getFloatCastKind($self->semStack[$1]);
            $$ = new Expr\Cast\Double($self->semStack[$2], $attrs); }
    | T_STRING_CAST expr                                    { $$ = new Expr\Cast\String_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_ARRAY_CAST expr                                     { $$ = new Expr\Cast\Array_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_OBJECT_CAST expr                                    { $$ = new Expr\Cast\Object_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_BOOL_CAST expr                                      { $$ = new Expr\Cast\Bool_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_UNSET_CAST expr                                     { $$ = new Expr\Cast\Unset_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_EXIT ctor_arguments
          { $$ = $self->createExitExpr($self->semStack[$1], $1, $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | '@' expr                                              { $$ = new Expr\ErrorSuppress($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | scalar
    | '`' backticks_expr '`'                                { $$ = new Expr\ShellExec($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_PRINT expr                                          { $$ = new Expr\Print_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_YIELD                                               { $$ = new Expr\Yield_(null, null, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_YIELD expr                                          { $$ = new Expr\Yield_($self->semStack[$2], null, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_YIELD expr T_DOUBLE_ARROW expr                      { $$ = new Expr\Yield_($self->semStack[$4], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_YIELD_FROM expr                                     { $$ = new Expr\YieldFrom($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_THROW expr                                          { $$ = new Expr\Throw_($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }

    | T_FN optional_ref '(' parameter_list ')' optional_return_type T_DOUBLE_ARROW expr %prec T_THROW
          { $$ = new Expr\ArrowFunction(['static' => false, 'byRef' => $self->semStack[$2], 'params' => $self->semStack[$4], 'returnType' => $self->semStack[$6], 'expr' => $self->semStack[$8], 'attrGroups' => []], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_STATIC T_FN optional_ref '(' parameter_list ')' optional_return_type T_DOUBLE_ARROW expr %prec T_THROW
          { $$ = new Expr\ArrowFunction(['static' => true, 'byRef' => $self->semStack[$3], 'params' => $self->semStack[$5], 'returnType' => $self->semStack[$7], 'expr' => $self->semStack[$9], 'attrGroups' => []], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_FUNCTION optional_ref '(' parameter_list ')' lexical_vars optional_return_type block_or_error
          { $$ = new Expr\Closure(['static' => false, 'byRef' => $self->semStack[$2], 'params' => $self->semStack[$4], 'uses' => $self->semStack[$6], 'returnType' => $self->semStack[$7], 'stmts' => $self->semStack[$8], 'attrGroups' => []], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_STATIC T_FUNCTION optional_ref '(' parameter_list ')' lexical_vars optional_return_type       block_or_error
          { $$ = new Expr\Closure(['static' => true, 'byRef' => $self->semStack[$3], 'params' => $self->semStack[$5], 'uses' => $self->semStack[$7], 'returnType' => $self->semStack[$8], 'stmts' => $self->semStack[$9], 'attrGroups' => []], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }

    | attributes T_FN optional_ref '(' parameter_list ')' optional_return_type T_DOUBLE_ARROW expr %prec T_THROW
          { $$ = new Expr\ArrowFunction(['static' => false, 'byRef' => $self->semStack[$3], 'params' => $self->semStack[$5], 'returnType' => $self->semStack[$7], 'expr' => $self->semStack[$9], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | attributes T_STATIC T_FN optional_ref '(' parameter_list ')' optional_return_type T_DOUBLE_ARROW expr %prec T_THROW
          { $$ = new Expr\ArrowFunction(['static' => true, 'byRef' => $self->semStack[$4], 'params' => $self->semStack[$6], 'returnType' => $self->semStack[$8], 'expr' => $self->semStack[$10], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | attributes T_FUNCTION optional_ref '(' parameter_list ')' lexical_vars optional_return_type block_or_error
          { $$ = new Expr\Closure(['static' => false, 'byRef' => $self->semStack[$3], 'params' => $self->semStack[$5], 'uses' => $self->semStack[$7], 'returnType' => $self->semStack[$8], 'stmts' => $self->semStack[$9], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | attributes T_STATIC T_FUNCTION optional_ref '(' parameter_list ')' lexical_vars optional_return_type       block_or_error
          { $$ = new Expr\Closure(['static' => true, 'byRef' => $self->semStack[$4], 'params' => $self->semStack[$6], 'uses' => $self->semStack[$8], 'returnType' => $self->semStack[$9], 'stmts' => $self->semStack[$10], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

anonymous_class:
      optional_attributes class_entry_type ctor_arguments extends_from implements_list '{' class_statement_list '}'
          { $$ = array(new Stmt\Class_(null, ['type' => $self->semStack[$2], 'extends' => $self->semStack[$4], 'implements' => $self->semStack[$5], 'stmts' => $self->semStack[$7], 'attrGroups' => $self->semStack[$1]], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])), $self->semStack[$3]);
            $self->checkClass($$[0], -1); }
;

new_dereferenceable:
      T_NEW class_name_reference argument_list              { $$ = new Expr\New_($self->semStack[$2], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_NEW anonymous_class
          { list($class, $ctorArgs) = $self->semStack[$2]; $$ = new Expr\New_($class, $ctorArgs, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

new_non_dereferenceable:
      T_NEW class_name_reference                            { $$ = new Expr\New_($self->semStack[$2], [], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

new_expr:
      new_dereferenceable
    | new_non_dereferenceable
;

lexical_vars:
      /* empty */                                           { $$ = array(); }
    | T_USE '(' lexical_var_list ')'                        { $$ = $self->semStack[$3]; }
;

lexical_var_list:
      non_empty_lexical_var_list optional_comma
;

non_empty_lexical_var_list:
      lexical_var                                           { $$ = array($self->semStack[$1]); }
    | non_empty_lexical_var_list ',' lexical_var            { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
;

lexical_var:
      optional_ref plain_variable                           { $$ = new Node\ClosureUse($self->semStack[$2], $self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

name_readonly:
      T_READONLY                                            { $$ = new Name($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

function_call:
      name argument_list                                    { $$ = new Expr\FuncCall($self->semStack[$1], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | name_readonly argument_list                           { $$ = new Expr\FuncCall($self->semStack[$1], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | callable_expr argument_list                           { $$ = new Expr\FuncCall($self->semStack[$1], $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | class_name_or_var T_PAAMAYIM_NEKUDOTAYIM member_name argument_list
          { $$ = new Expr\StaticCall($self->semStack[$1], $self->semStack[$3], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

class_name:
      T_STATIC                                              { $$ = new Name($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | name
;

name:
      T_STRING                                              { $$ = new Name($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_NAME_QUALIFIED                                      { $$ = new Name($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_NAME_FULLY_QUALIFIED                                { $$ = new Name\FullyQualified(substr($self->semStack[$1], 1), $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_NAME_RELATIVE                                       { $$ = new Name\Relative(substr($self->semStack[$1], 10), $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

class_name_reference:
      class_name
    | new_variable
    | '(' expr ')'                                          { $$ = $self->semStack[$2]; }
    | error                                                 { $$ = new Expr\Error($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->errorState = 2; }
;

class_name_or_var:
      class_name
    | fully_dereferenceable
;

backticks_expr:
      /* empty */                                           { $$ = array(); }
    | encaps_string_part
          { $$ = array($self->semStack[$1]); foreach ($$ as $s) { if ($s instanceof Node\InterpolatedStringPart) { $s->value = Node\Scalar\String_::parseEscapeSequences($s->value, '`', $self->phpVersion->supportsUnicodeEscapes()); } }; }
    | encaps_list                                           { foreach ($self->semStack[$1] as $s) { if ($s instanceof Node\InterpolatedStringPart) { $s->value = Node\Scalar\String_::parseEscapeSequences($s->value, '`', $self->phpVersion->supportsUnicodeEscapes()); } }; $$ = $self->semStack[$1]; }
;

ctor_arguments:
      /* empty */                                           { $$ = array(); }
    | argument_list
;

constant:
      name                                                  { $$ = new Expr\ConstFetch($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_LINE                                                { $$ = new Scalar\MagicConst\Line($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_FILE                                                { $$ = new Scalar\MagicConst\File($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DIR                                                 { $$ = new Scalar\MagicConst\Dir($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_CLASS_C                                             { $$ = new Scalar\MagicConst\Class_($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_TRAIT_C                                             { $$ = new Scalar\MagicConst\Trait_($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_METHOD_C                                            { $$ = new Scalar\MagicConst\Method($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_FUNC_C                                              { $$ = new Scalar\MagicConst\Function_($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_NS_C                                                { $$ = new Scalar\MagicConst\Namespace_($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_PROPERTY_C                                          { $$ = new Scalar\MagicConst\Property($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

class_constant:
      class_name_or_var T_PAAMAYIM_NEKUDOTAYIM identifier_maybe_reserved
          { $$ = new Expr\ClassConstFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | class_name_or_var T_PAAMAYIM_NEKUDOTAYIM '{' expr '}'
          { $$ = new Expr\ClassConstFetch($self->semStack[$1], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    /* We interpret an isolated FOO:: as an unfinished class constant fetch. It could also be
       an unfinished static property fetch or unfinished scoped call. */
    | class_name_or_var T_PAAMAYIM_NEKUDOTAYIM error
          { $$ = new Expr\ClassConstFetch($self->semStack[$1], new Expr\Error($self->getAttributes($self->tokenStartStack[$3],  $self->tokenEndStack[$3])), $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->errorState = 2; }
;

array_short_syntax:
      '[' array_pair_list ']'
          { $attrs = $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]); $attrs['kind'] = Expr\Array_::KIND_SHORT;
            $$ = new Expr\Array_($self->semStack[$2], $attrs); }
;

dereferenceable_scalar:
      T_ARRAY '(' array_pair_list ')'
          { $attrs = $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]); $attrs['kind'] = Expr\Array_::KIND_LONG;
            $$ = new Expr\Array_($self->semStack[$3], $attrs);
            $self->createdArrays->attach($$); }
    | array_short_syntax                                    { $$ = $self->semStack[$1]; $self->createdArrays->attach($$); }
    | T_CONSTANT_ENCAPSED_STRING
          { $$ = Scalar\String_::fromString($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->phpVersion->supportsUnicodeEscapes()); }
    | '"' encaps_list '"'
          { $attrs = $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]); $attrs['kind'] = Scalar\String_::KIND_DOUBLE_QUOTED;
            foreach ($self->semStack[$2] as $s) { if ($s instanceof Node\InterpolatedStringPart) { $s->value = Node\Scalar\String_::parseEscapeSequences($s->value, '"', $self->phpVersion->supportsUnicodeEscapes()); } }; $$ = new Scalar\InterpolatedString($self->semStack[$2], $attrs); }
;

scalar:
      T_LNUMBER
          { $$ = $self->parseLNumber($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->phpVersion->allowsInvalidOctals()); }
    | T_DNUMBER                                             { $$ = Scalar\Float_::fromString($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | dereferenceable_scalar
    | constant
    | class_constant
    | T_START_HEREDOC T_ENCAPSED_AND_WHITESPACE T_END_HEREDOC
          { $$ = $self->parseDocString($self->semStack[$1], $self->semStack[$2], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->getAttributes($self->tokenStartStack[$3],  $self->tokenEndStack[$3]), true); }
    | T_START_HEREDOC T_END_HEREDOC
          { $$ = $self->parseDocString($self->semStack[$1], '', $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->getAttributes($self->tokenStartStack[$2],  $self->tokenEndStack[$2]), true); }
    | T_START_HEREDOC encaps_list T_END_HEREDOC
          { $$ = $self->parseDocString($self->semStack[$1], $self->semStack[$2], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), $self->getAttributes($self->tokenStartStack[$3],  $self->tokenEndStack[$3]), true); }
;

optional_expr:
      /* empty */                                           { $$ = null; }
    | expr
;

fully_dereferenceable:
      variable
    | '(' expr ')'                                          { $$ = $self->semStack[$2]; }
    | dereferenceable_scalar
    | class_constant
    | new_dereferenceable
;

array_object_dereferenceable:
      fully_dereferenceable
    | constant
;

callable_expr:
      callable_variable
    | '(' expr ')'                                          { $$ = $self->semStack[$2]; }
    | dereferenceable_scalar
    | new_dereferenceable
;

callable_variable:
      simple_variable
    | array_object_dereferenceable '[' optional_expr ']'     { $$ = new Expr\ArrayDimFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | function_call
    | array_object_dereferenceable T_OBJECT_OPERATOR property_name argument_list
          { $$ = new Expr\MethodCall($self->semStack[$1], $self->semStack[$3], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | array_object_dereferenceable T_NULLSAFE_OBJECT_OPERATOR property_name argument_list
          { $$ = new Expr\NullsafeMethodCall($self->semStack[$1], $self->semStack[$3], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

optional_plain_variable:
      /* empty */                                           { $$ = null; }
    | plain_variable
;

variable:
      callable_variable
    | static_member
    | array_object_dereferenceable T_OBJECT_OPERATOR property_name
          { $$ = new Expr\PropertyFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | array_object_dereferenceable T_NULLSAFE_OBJECT_OPERATOR property_name
          { $$ = new Expr\NullsafePropertyFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

simple_variable:
      plain_variable
    | '$' '{' expr '}'                                      { $$ = new Expr\Variable($self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | '$' simple_variable                                   { $$ = new Expr\Variable($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | '$' error                                             { $$ = new Expr\Variable(new Expr\Error($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])), $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->errorState = 2; }
;

static_member_prop_name:
      simple_variable
          { $var = $self->semStack[$1]->name; $$ = \is_string($var) ? new Node\VarLikeIdentifier($var, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])) : $var; }
;

static_member:
      class_name_or_var T_PAAMAYIM_NEKUDOTAYIM static_member_prop_name
          { $$ = new Expr\StaticPropertyFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

new_variable:
      simple_variable
    | new_variable '[' optional_expr ']'                    { $$ = new Expr\ArrayDimFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | new_variable T_OBJECT_OPERATOR property_name          { $$ = new Expr\PropertyFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | new_variable T_NULLSAFE_OBJECT_OPERATOR property_name { $$ = new Expr\NullsafePropertyFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | class_name T_PAAMAYIM_NEKUDOTAYIM static_member_prop_name
          { $$ = new Expr\StaticPropertyFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | new_variable T_PAAMAYIM_NEKUDOTAYIM static_member_prop_name
          { $$ = new Expr\StaticPropertyFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

member_name:
      identifier_maybe_reserved
    | '{' expr '}'                                          { $$ = $self->semStack[$2]; }
    | simple_variable
;

property_name:
      identifier_not_reserved
    | '{' expr '}'                                          { $$ = $self->semStack[$2]; }
    | simple_variable
    | error                                                 { $$ = new Expr\Error($self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $self->errorState = 2; }
;

list_expr:
      T_LIST '(' inner_array_pair_list ')'
          { $$ = new Expr\List_($self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); $$->setAttribute('kind', Expr\List_::KIND_LIST);
            $self->postprocessList($$); }
;

array_pair_list:
      inner_array_pair_list
          { $$ = $self->semStack[$1]; $end = count($$)-1; if ($$[$end]->value instanceof Expr\Error) array_pop($$); }
;

comma_or_error:
      ','
    | error
          { /* do nothing -- prevent default action of $$=$self->semStack[$1]. See $551. */ }
;

inner_array_pair_list:
      inner_array_pair_list comma_or_error array_pair       { $self->semStack[$1][] = $self->semStack[$3]; $$ = $self->semStack[$1]; }
    | array_pair                                            { $$ = array($self->semStack[$1]); }
;

array_pair:
      expr                                                  { $$ = new Node\ArrayItem($self->semStack[$1], null, false, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | ampersand variable                                    { $$ = new Node\ArrayItem($self->semStack[$2], null, true, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | list_expr                                             { $$ = new Node\ArrayItem($self->semStack[$1], null, false, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_DOUBLE_ARROW expr                              { $$ = new Node\ArrayItem($self->semStack[$3], $self->semStack[$1], false, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_DOUBLE_ARROW ampersand variable                { $$ = new Node\ArrayItem($self->semStack[$4], $self->semStack[$1], true, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | expr T_DOUBLE_ARROW list_expr                         { $$ = new Node\ArrayItem($self->semStack[$3], $self->semStack[$1], false, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_ELLIPSIS expr                                       { $$ = new Node\ArrayItem($self->semStack[$2], null, false, $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]), true); }
    | /* empty */
        { /* Create an Error node now to remember the position. We'll later either report an error,
             or convert this into a null element, depending on whether this is a creation or destructuring context. */
          $attrs = $self->createEmptyElemAttributes($self->tokenPos);
          $$ = new Node\ArrayItem(new Expr\Error($attrs), null, false, $attrs); }
;

encaps_list:
      encaps_list encaps_var                                { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; }
    | encaps_list encaps_string_part                        { $self->semStack[$1][] = $self->semStack[$2]; $$ = $self->semStack[$1]; }
    | encaps_var                                            { $$ = array($self->semStack[$1]); }
    | encaps_string_part encaps_var                         { $$ = array($self->semStack[$1], $self->semStack[$2]); }
;

encaps_string_part:
      T_ENCAPSED_AND_WHITESPACE
          { $attrs = $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos]); $attrs['rawValue'] = $self->semStack[$1]; $$ = new Node\InterpolatedStringPart($self->semStack[$1], $attrs); }
;

encaps_str_varname:
      T_STRING_VARNAME                                      { $$ = new Expr\Variable($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
;

encaps_var:
      plain_variable
    | plain_variable '[' encaps_var_offset ']'              { $$ = new Expr\ArrayDimFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | plain_variable T_OBJECT_OPERATOR identifier_not_reserved
          { $$ = new Expr\PropertyFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | plain_variable T_NULLSAFE_OBJECT_OPERATOR identifier_not_reserved
          { $$ = new Expr\NullsafePropertyFetch($self->semStack[$1], $self->semStack[$3], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DOLLAR_OPEN_CURLY_BRACES expr '}'                   { $$ = new Expr\Variable($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME '}'       { $$ = new Expr\Variable($self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_DOLLAR_OPEN_CURLY_BRACES encaps_str_varname '[' expr ']' '}'
          { $$ = new Expr\ArrayDimFetch($self->semStack[$2], $self->semStack[$4], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_CURLY_OPEN variable '}'                             { $$ = $self->semStack[$2]; }
;

encaps_var_offset:
      T_STRING                                              { $$ = new Scalar\String_($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | T_NUM_STRING                                          { $$ = $self->parseNumString($self->semStack[$1], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | '-' T_NUM_STRING                                      { $$ = $self->parseNumString('-' . $self->semStack[$2], $self->getAttributes($self->tokenStartStack[$1], $self->tokenEndStack[$stackPos])); }
    | plain_variable
;

%%
