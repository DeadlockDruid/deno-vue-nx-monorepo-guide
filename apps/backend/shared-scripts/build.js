import * as esbuild from 'npm:esbuild@0.23.0';
import { denoPlugins } from 'jsr:@duesabati/esbuild-deno-plugin';
import { resolve, toFileUrl } from 'https://deno.land/std@0.224.0/path/mod.ts';

// Parse CLI arguments
const args = Deno.args.reduce((acc, arg, index, arr) => {
  if (arg.startsWith('--')) acc[arg.replace('--', '')] = arr[index + 1];
  return acc;
}, {});

// Extract paths and options
const importMap = args['import-map'];
const entryPoint = args['entry-point'];
const outputDir = args['output-dir'];

// Resolve paths relative to cwd (project root)
const importMapPath = toFileUrl(resolve(importMap)).href; // Convert to file URL
const entryPointPath = resolve(entryPoint); // Absolute path for entry point
const outputDirPath = resolve(outputDir); // Absolute path for output directory

await esbuild.build({
  plugins: [
    ...denoPlugins({
      importMapURL: importMapPath, // Resolved absolute file URL
    }),
  ],
  entryPoints: [entryPointPath], // Resolved absolute entry point path
  bundle: true,
  outfile: `${outputDirPath}/bundle.js`, // Resolved absolute output path
  format: 'esm',
  platform: 'neutral', // Ensure Deno compatibility
  treeShaking: true,
});

console.log(`Build completed: ${outputDirPath}/bundle.js`);

esbuild.stop();
