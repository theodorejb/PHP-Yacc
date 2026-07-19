<?php

declare(strict_types=1);

namespace PhpYacc\CodeGen;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use PhpYacc\Compress\CompressResult;
use PhpYacc\Exception\TemplateException;
use PhpYacc\Grammar\Context;
use PhpYacc\CodeGen\Language\PHP;

class TemplateTest extends TestCase
{
    public static function provideConditionals(): array
    {
        return [
            'if true' => [
                <<<'TEMPLATE'
                    $if -a
                    A
                    $endif
                    B
                    TEMPLATE,
                ['aflag' => true],
                "A\nB\n",
            ],
            'if false' => [
                <<<'TEMPLATE'
                    $if -a
                    A
                    $endif
                    B
                    TEMPLATE,
                ['aflag' => false],
                "B\n",
            ],
            'ifnot true' => [
                <<<'TEMPLATE'
                    $ifnot -a
                    A
                    $endif
                    B
                    TEMPLATE,
                ['aflag' => true],
                "B\n",
            ],
            'ifnot false' => [
                <<<'TEMPLATE'
                    $ifnot -a
                    A
                    $endif
                    B
                    TEMPLATE,
                ['aflag' => false],
                "A\nB\n",
            ],
            'nested if both true' => [
                <<<'TEMPLATE'
                    $if -a
                    A
                    $if -t
                    B
                    $endif
                    C
                    $endif
                    D
                    TEMPLATE,
                ['aflag' => true, 'tflag' => true],
                "A\nB\nC\nD\n",
            ],
            'nested if outer true inner false' => [
                <<<'TEMPLATE'
                    $if -a
                    A
                    $if -t
                    B
                    $endif
                    C
                    $endif
                    D
                    TEMPLATE,
                ['aflag' => true, 'tflag' => false],
                "A\nC\nD\n",
            ],
            'nested if outer false inner true' => [
                <<<'TEMPLATE'
                    $if -a
                    A
                    $if -t
                    B
                    $endif
                    C
                    $endif
                    D
                    TEMPLATE,
                ['aflag' => false, 'tflag' => true],
                "D\n",
            ],
            'nested if both false' => [
                <<<'TEMPLATE'
                    $if -a
                    A
                    $if -t
                    B
                    $endif
                    C
                    $endif
                    D
                    TEMPLATE,
                ['aflag' => false, 'tflag' => false],
                "D\n",
            ],
            'nested ifnot inside if (outer true, ifnot cond true so skip)' => [
                <<<'TEMPLATE'
                    $if -a
                    A
                    $ifnot -t
                    B
                    $endif
                    C
                    $endif
                    D
                    TEMPLATE,
                ['aflag' => true, 'tflag' => true],
                "A\nC\nD\n",
            ],
            'nested ifnot inside if (outer true, ifnot cond false so keep)' => [
                <<<'TEMPLATE'
                    $if -a
                    A
                    $ifnot -t
                    B
                    $endif
                    C
                    $endif
                    D
                    TEMPLATE,
                ['aflag' => true, 'tflag' => false],
                "A\nB\nC\nD\n",
            ],
            'adjacent ifs' => [
                <<<'TEMPLATE'
                    $if -a
                    A
                    $endif
                    $if -t
                    B
                    $endif
                    C
                    TEMPLATE,
                ['aflag' => true, 'tflag' => false],
                "A\nC\n",
            ],
        ];
    }

    #[DataProvider("provideConditionals")]
    public function testConditionals(string $template, array $contextFlags, string $expected): void
    {
        $context = new Context('YY');
        foreach ($contextFlags as $flag => $value) {
            $context->$flag = $value;
        }

        $templateObj = new Template(new PHP(), $template, $context);
        $this->assertSame($expected, $templateObj->render(new CompressResult()));
    }

    public function testEndifWithoutIfThrows(): void
    {
        $template = <<<'TEMPLATE'
            A
            $endif
            B
            TEMPLATE;
        $context = new Context('YY');
        $templateObj = new Template(new PHP(), $template, $context);

        $this->expectException(TemplateException::class);
        $templateObj->render(new CompressResult());
    }

    public function testUnterminatedIfThrows(): void
    {
        $template = <<<'TEMPLATE'
            $if -a
            A
            B
            TEMPLATE;
        $context = new Context('YY');
        $context->aflag = true;
        $templateObj = new Template(new PHP(), $template, $context);

        $this->expectException(TemplateException::class);
        $templateObj->render(new CompressResult());
    }
}
