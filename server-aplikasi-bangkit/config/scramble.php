<?php

use Dedoc\Scramble\Http\Middleware\RestrictedDocsAccess;

return [
    'api_path' => 'api',
    'api_domain' => null,
    'export_path' => 'api.json',

    'info' => [
        'version' => env('API_VERSION', '1.0.0'),
        'description' => 'API documentation for Server Aplikasi Bangkit API.',
    ],

    'ui' => [
        'title' => 'Server Aplikasi Bangkit API Docs',
        'theme' => 'dark',
        'layout' => 'sidebar',
        'hide_try_it' => false,
        'try_it_credentials_policy' => 'include',
    ],

    'servers' => null,

    'enum_cases_description_strategy' => 'extension',

    'middleware' => [
        'web',
        // Uncomment below in production
        // RestrictedDocsAccess::class,
    ],

    'extensions' => [],
];
