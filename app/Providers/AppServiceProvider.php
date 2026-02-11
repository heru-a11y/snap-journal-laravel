<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Storage;
use Google\Cloud\Storage\StorageClient;
use League\Flysystem\GoogleCloudStorage\GoogleCloudStorageAdapter;
use League\Flysystem\Filesystem;
use Illuminate\Filesystem\FilesystemAdapter;
use Illuminate\Support\Facades\URL;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void {}

    public function boot(): void
    {
            if (config('app.env') !== 'local') {
               URL::forceScheme('https');
            }

            Storage::extend('gcs', function ($app, $config) {
            
            // Ambil konfigurasi dari filesystems.php
            $keyConfig = $config['key_file'] ?? null;
            
            $clientConfig = [
                'projectId' => $config['project_id'] ?? env('GOOGLE_CLOUD_PROJECT_ID'),
            ];

            // --- LOGIKA CERDAS ---
            if (is_array($keyConfig)) {
                // Jika Array (dari ENV Base64), pakai 'keyFile'
                $clientConfig['keyFile'] = $keyConfig;
            } else {
                // Jika String (Path file lokal), pakai 'keyFilePath'
                // Gunakan base_path() hanya jika itu string
                $clientConfig['keyFilePath'] = $keyConfig ? base_path($keyConfig) : null;
            }
            // ---------------------

            $storageClient = new StorageClient($clientConfig);

            $bucket = $storageClient->bucket($config['bucket']);

            $adapter = new GoogleCloudStorageAdapter(
                $bucket,
                $config['path_prefix'] ?? ''
            );

            $filesystem = new Filesystem($adapter);

            return new FilesystemAdapter($filesystem, $adapter, $config);
        });
    }
}
