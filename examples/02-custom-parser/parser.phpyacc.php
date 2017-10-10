<?php

/* Prototype file of PHP parser.
 * Written by Masato Bito
 * This file is PUBLIC DOMAIN.
 */

$buffer = null;
$token = null;
$toktype = null;

define('YYERRTOK', 0);
define('NUMBER', 0);
define('NEG', 0);


/*
  #define yyclearin (yychar = -1)
  #define yyerrok (yyerrflag = 0)
  #define YYRECOVERING (yyerrflag != 0)
  #define YYERROR  goto yyerrlab
*/


/** Debug mode flag **/
$yydebug = false;

/** lexical element object **/
$yylval = null;

function yyprintln($msg)
{
    echo "$msg\n";
}

function yyflush()
{
    return;
}

$yydebug = true;

$yyterminals = array(
    "EOF",
    "error",
    "NUMBER",
    "'+'",
    "'-'",
    "'*'",
    "'/'",
    "'^'",
    "'('",
    "')'"
    , "???"
    );


function yytokname($n)
{
    switch ($n) {
    case 0: return 'error';
    case 0: return 'NUMBER';
    case 43: return '\'+\'';
    case 45: return '\'-\'';
    case 42: return '\'*\'';
    case 47: return '\'/\'';
    case 94: return '\'^\'';
    case 0: return '\'(\'';
    case 0: return '\')\'';
        default:
            return "???";
    }
}

$yyproduction = array(
    "\$start : statement",
    "statement : /* empty */",
    "statement : expression",
    "expression : factor",
    "expression : expression '*' expression",
    "expression : expression '/' expression",
    "expression : expression '+' expression",
    "expression : expression '-' expression",
    "expression : expression '^' expression",
    "expression : '-' expression",
    "factor : NUMBER",
    "factor : '(' expression ')'"
);


/* Traditional Debug Mode */
function YYTRACE_NEWSTATE($state, $sym)
{
    global $yydebug, $yyterminals;
    if ($yydebug)
        yyprintln("% State " . $state . ", Lookahead "
            . ($sym < 0 ? "--none--" : $yyterminals[$sym]));
}

function YYTRACE_READ($sym)
{
    global $yydebug, $yyterminals;
    if ($yydebug)
        yyprintln("% Reading " . $yyterminals[$sym]);
}

function YYTRACE_SHIFT($sym)
{
    global $yydebug, $yyterminals;
    if ($yydebug)
        yyprintln("% Shift " . $yyterminals[$sym]);
}

function YYTRACE_ACCEPT()
{
    global $yydebug;
    if ($yydebug) yyprintln("% Accepted.");
}

function YYTRACE_REDUCE($n)
{
    global $yydebug, $yyproduction;
    if ($yydebug)
        yyprintln("% Reduce by (" . $n . ") " . $yyproduction[$n]);
}

function YYTRACE_POP($state)
{
    global $yydebug;
    if ($yydebug)
        yyprintln("% Recovering, uncovers state " . $state);
}

function YYTRACE_DISCARD($sym)
{
    global $yydebug, $yyterminals;
    if ($yydebug)
        yyprintln("% Discard " . $yyterminals[$sym]);
}


$yytranslate = array(
        9,   10,   10,   10,   10,   10,   10,   10,   10,   10,
       10,   10,   10,   10,   10,   10,   10,   10,   10,   10,
       10,   10,   10,   10,   10,   10,   10,   10,   10,   10,
       10,   10,   10,   10,   10,   10,   10,   10,   10,   10,
       10,   10,    5,    3,   10,    4,   10,    6,   10,   10,
       10,   10,   10,   10,   10,   10,   10,   10,   10,   10,
       10,   10,   10,   10,   10,   10,   10,   10,   10,   10,
       10,   10,   10,   10,   10,   10,   10,   10,   10,   10,
       10,   10,   10,   10,   10,   10,   10,   10,   10,   10,
       10,   10,   10,   10,    7
  );

define('YYBADCH', 10);
define('YYMAXLEX', 95);
define('YYTERMS', 10);
define('YYNONTERMS', 5);

$yyaction = array(
        5,    6,    7,    8,    9,    0,   19,    5,    6,    7,
        8,    9,   16,    9,    3,    0,    0,    0,    4,    7,
        8,    9
  );

define('YYLAST', 22);

$yycheck = array(
        3,    4,    5,    6,    7,    0,    9,    3,    4,    5,
        6,    7,    2,    7,    4,   -1,   -1,   -1,    8,    5,
        6,    7
  );

$yybase = array(
       10,   -3,    4,   10,   10,   10,   10,   10,   10,   10,
       14,   14,    5,    6,    6,    6,    0,    0,    0,    0
  );

define('YY2TBLSTATE', 0);

$yydefault = array(
        1,32767,    2,32767,32767,32767,32767,32767,32767,32767,
        6,    7,32767,    4,    5,    8,   10,    3,    9,   11
  );



$yygoto = array(
       18,    1,   10,   11,   13,   14,   15
  );

define('YYGLAST', 7);

$yygcheck = array(
        2,    2,    2,    2,    2,    2,    2
  );

$yygbase = array(
        0,    0,   -3,    0,    0
  );

$yygdefault = array(
    -32768,   12,    2,   17,-32768
  );

$yylhs = array(
        0,    1,    1,    2,    2,    2,    2,    2,    2,    2,
        3,    3
  );

$yylen = array(
        1,    0,    1,    1,    3,    3,    3,    3,    3,    2,
        1,    3
  );

define('YYSTATES', 20);
define('YYNLSTATES', 20);
define('YYINTERRTOK', 9);
define('YYUNEXPECTED', 32767);
define('YYDEFAULT', -32766);

/*
 * Parser entry point
 */

function yyparse()
{
    global $buffer, $token, $toktype, $yyaction, $yybase, $yycheck, $yydebug,
           $yydebug, $yydefault, $yygbase, $yygcheck, $yygdefault, $yygoto, $yylen,
           $yylhs, $yylval, $yyproduction, $yyterminals, $yytranslate;

    $yyastk = array();
    $yysstk = array();

    $yyn = $yyl = 0;
    $yystate = 0;
    $yychar = -1;

    $yysp = 0;
    $yysstk[$yysp] = 0;
    $yyerrflag = 0;
    while (true) {
        YYTRACE_NEWSTATE($yystate, $yychar);
    if ($yybase[$yystate] == 0)
        $yyn = $yydefault[$yystate];
    else {
        if ($yychar < 0) {
            if (($yychar = yylex()) <= 0) $yychar = 0;
            $yychar = $yychar < YYMAXLEX ? $yytranslate[$yychar] : YYBADCH;
            YYTRACE_READ($yychar);
      }

        if ((($yyn = $yybase[$yystate] + $yychar) >= 0
                && $yyn < YYLAST && $yycheck[$yyn] == $yychar
                || ($yystate < YY2TBLSTATE
                    && ($yyn = $yybase[$yystate + YYNLSTATES] + $yychar) >= 0
                    && $yyn < YYLAST && $yycheck[$yyn] == $yychar))
            && ($yyn = $yyaction[$yyn]) != YYDEFAULT) {
            /*
             * >= YYNLSTATE: shift and reduce
             * > 0: shift
             * = 0: accept
             * < 0: reduce
             * = -YYUNEXPECTED: error
             */
            if ($yyn > 0) {
                /* shift */
                YYTRACE_SHIFT($yychar);
          $yysp++;

          $yysstk[$yysp] = $yystate = $yyn;
          $yyastk[$yysp] = $yylval;
          $yychar = -1;

          if ($yyerrflag > 0)
              $yyerrflag--;
          if ($yyn < YYNLSTATES)
              continue;

          /* $yyn >= YYNLSTATES means shift-and-reduce */
          $yyn -= YYNLSTATES;
        } else
                $yyn = -$yyn;
        } else
            $yyn = $yydefault[$yystate];
    }

    while (true) {
        /* reduce/error */
        if ($yyn == 0) {
            /* accept */
            YYTRACE_ACCEPT();
        yyflush();
        return 0;
      }
        else if ($yyn != YYUNEXPECTED) {
            /* reduce */
            $yyl = $yylen[$yyn];
            $n = $yysp-$yyl+1;
            $yyval = isset($yyastk[$n]) ? $yyastk[$n] : null;
            YYTRACE_REDUCE($yyn);
        /* Following line will be replaced by reduce actions */
        switch($yyn) {
            case 1:
                { exit(0); } break;
            case 2:
                { printf("= %f\n", $yyastk[$yysp-(1-1)]); } break;
            case 3:
                { $yyval = $yyastk[$yysp-(1-1)]; } break;
            case 4:
                { $yyval = $yyastk[$yysp-(3-1)] * $yyastk[$yysp-(3-3)]; } break;
            case 5:
                { $yyval = $yyastk[$yysp-(3-1)]  $yyastk[$yysp-(3-3)]; } break;
            case 6:
                { $yyval = $yyastk[$yysp-(3-1)] + $yyastk[$yysp-(3-3)]; } break;
            case 7:
                { $yyval = $yyastk[$yysp-(3-1)] - $yyastk[$yysp-(3-3)]; } break;
            case 8:
                { $yyval = pow($yyastk[$yysp-(3-1)], $yyastk[$yysp-(3-3)]); } break;
            case 9:
                { $yyval = -$yyastk[$yysp-(2-2)]; } break;
            case 10:
                { $yyval = $yyastk[$yysp-(1-1)]; } break;
            case 11:
                { $yyval = $yyastk[$yysp-(3-2)]; } break;
        }
        /* Goto - shift nonterminal */
        $yysp -= $yyl;
        $yyn = $yylhs[$yyn];
        if (($yyp = $yygbase[$yyn] + $yysstk[$yysp]) >= 0 && $yyp < YYGLAST
            && $yygcheck[$yyp] == $yyn)
            $yystate = $yygoto[$yyp];
        else
            $yystate = $yygdefault[$yyn];

        $yysp++;

        $yysstk[$yysp] = $yystate;
        $yyastk[$yysp] = $yyval;
      }
        else {
            /* error */
            switch ($yyerrflag) {
                case 0:
                    yyerror("syntax error");
                case 1:
                case 2:
                    $yyerrflag = 3;
                    /* Pop until error-expecting state uncovered */

                    while (!(($yyn = $yybase[$yystate] + YYINTERRTOK) >= 0
                        && $yyn < YYLAST && $yycheck[$yyn] == YYINTERRTOK
                        || ($yystate < YY2TBLSTATE
                            && ($yyn = $yybase[$yystate + YYNLSTATES] + YYINTERRTOK) >= 0
                            && $yyn < YYLAST && $yycheck[$yyn] == YYINTERRTOK))) {
                        if ($yysp <= 0) {
                            yyflush();
                            return 1;
                        }
                        $yystate = $yysstk[--$yysp];
                        YYTRACE_POP($yystate);
          }
                    $yyn = $yyaction[$yyn];
                YYTRACE_SHIFT(YYINTERRTOK);
          $yysstk[++$yysp] = $yystate = $yyn;
          break;

                case 3:
                YYTRACE_DISCARD($yychar);
          if ($yychar == 0) {
              yyflush();
              return 1;
          }
          $yychar = -1;
          break;
            }
        }

        if ($yystate < YYNLSTATES)
            break;
        /* >= YYNLSTATES means shift-and-reduce */
        $yyn = $yystate - YYNLSTATES;
    }
  }
}

