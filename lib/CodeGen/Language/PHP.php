<?php

/**
 * Created by PhpStorm.
 * User: ircmaxell
 * Date: 10/10/17
 * Time: 3:44 PM
 */

namespace PhpYacc\CodeGen\Language;

use PhpYacc\CodeGen\Language;

class PHP implements Language
{
    protected string $fileBuffer = '';

    public function begin(): void
    {
        $this->fileBuffer = '';
    }

    public function commit(): string
    {
        // Make sure there is exactly one trailing newline.
        $this->fileBuffer = rtrim($this->fileBuffer, "\n") . "\n";
        $result = $this->fileBuffer;
        $this->fileBuffer = '';
        return $result;
    }

    public function inline_comment(string $text): void
    {
        $this->fileBuffer .= '/* ' . $text . " */";
    }

    public function comment(string $text): void
    {
        $this->fileBuffer .= '//' . $text . "\n";
    }

    public function case_block(string $indent, int $num, string $value): void
    {
        $this->fileBuffer .= sprintf("%scase %d: return %s;\n", $indent, $num, var_export($value, true));
    }

    public function write(string $text): void
    {
        $this->fileBuffer .= $text;
    }

    public function writeQuoted(string $text): void
    {
        $regex = '(\\$(?=[a-zA-Z_])|")';
        $text = preg_replace($regex, "\\\\$0", $text);
        $this->fileBuffer .= $text;
    }
}
