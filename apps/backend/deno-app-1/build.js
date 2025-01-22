import * as esbuild from 'npm:esbuild@0.23.0';
import { denoPlugins } from 'jsr:@duesabati/esbuild-deno-plugin';

await esbuild.build({
  plugins: [
    ...denoPlugins({
      importMapURL: new URL('./merged_import_map.json', import.meta.url),
    }),
  ],
  entryPoints: ['./main.ts'],
  bundle: true,
  outfile: './dist/bundle.js',
  format: 'esm',
  platform: 'neutral', // Ensure Deno compatibility
  treeShaking: true,
});

console.log('Build completed: dist/bundle.js');

esbuild.stop();
