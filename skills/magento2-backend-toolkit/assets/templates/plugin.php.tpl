<?php

declare(strict_types=1);

namespace {Vendor}\{Module}\Plugin;

use {Target\Class\Full\Path};

class {PluginName}
{
    /**
     * Before plugin for {MethodName}
     *
     * @param \{TargetClass} $subject
     * @param mixed ...$args
     * @return array
     */
    // public function before{MethodName}(
    //     {TargetClass} $subject,
    //     ...$args
    // ): array {
    //     // Your logic here
    //     return [$args];
    // }

    /**
     * After plugin for {MethodName}
     *
     * @param \{TargetClass} $subject
     * @param mixed $result
     * @return mixed
     */
    // public function after{MethodName}(
    //     {TargetClass} $subject,
    //     $result
    // ) {
    //     // Modify $result here
    //     return $result;
    // }

    /**
     * Around plugin for {MethodName}
     *
     * @param \{TargetClass} $subject
     * @param callable $proceed
     * @param mixed ...$args
     * @return mixed
     */
    // public function around{MethodName}(
    //     {TargetClass} $subject,
    //     callable $proceed,
    //     ...$args
    // ) {
    //     // Before logic
    //     $result = $proceed(...$args);
    //     // After logic
    //     return $result;
    // }
}
