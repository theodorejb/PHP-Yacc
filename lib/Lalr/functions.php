<?php
declare(strict_types=1);

namespace PhpYacc\Lalr;

use PhpYacc\Grammar\Context;

function forEachMember(Context $ctx, Bitset $set)
{
    for ($v = 0; $v < $ctx->nsymbols; $v++) {
        if ($set->testBit($v)) {
            yield $v;
        }
    }
}


function isSameSet(Lr1 $left = null, Lr1 $right = null): bool
{
    $p = $left;
    $t = $right;
    while ($t !== null) {
        // Not using !== here intentionally
        if ($p === null || $p->item != $t->item) {
            return false;
        }
        $p = $p->next;
        $t = $t->next;
    }
    return $p === null || $p->isHeadItem();
}

function dumpSet(Context $ctx, Bitset $set): string
{
    $result = '';
    foreach ($ctx->symbols() as $symbol) {
        if ($set->testBit($symbol->code)) {
            $result .= "{$symbol->name} ";
        }
    }
    return $result;
}
