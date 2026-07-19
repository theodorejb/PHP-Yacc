<?php

require __DIR__ . "/../vendor/autoload.php";

use PhpYacc\Generator;
use PhpYacc\Grammar\Context;

const DEBUG = true;
const VERBOSE_DEBUG = true;

$options = CliOptions::fromArgv($argv);
$generator = new Generator;

if (isset($options->args[0])) {
    buildFolder($options, $generator, realpath($options->args[0]));
} else {
    buildAll($options, $generator, __DIR__);
}


function buildAll(CliOptions $options, Generator $generator, string $dir)
{
    $it = new DirectoryIterator($dir);
    foreach ($it as $file) {
        if (!$file->isDir() || $file->isDot()) {
            continue;
        }
        $dir = $file->getPathname();
        buildFolder($options, $generator, $dir);
    }
}


function buildFolder(CliOptions $options, Generator $generator, string $dir) {
    chdir($dir);
    echo "Building $dir\n";

    $grammar = "grammar.y";
    $skeleton = "parser.template.php";

    $errorFile = fopen("php://stderr", "w");
    $debugFile = DEBUG ? fopen("$dir/y.phpyacc.output", 'w') : null;
    $context = new Context($grammar, $errorFile, $debugFile, VERBOSE_DEBUG);
    $context->tflag = true;
    $generator->generate(
        $context,
        file_get_contents($grammar),
        file_get_contents($skeleton),
        "$dir/parser.phpyacc.php"
    );

}

class CliOptions {
    public $args = [];

    public static function fromArgv(array $argv) {
        $options = new self;
        foreach (array_slice($argv, 1) as $arg) {
            $options->args[] = $arg;
        }
        return $options;
    }
}
