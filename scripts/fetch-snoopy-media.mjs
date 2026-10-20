import { readFile, stat, rename, mkdir } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// Run only with permission to download and redistribute this media. Downloads
// use the explicitly catalogued uploads, never arbitrary search results.
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const directory = path.join(root, 'assets/video_collections/Snoopy');
const staging = path.join(root, '.dart_tool/snoopy-downloads');
const catalogue = JSON.parse(await readFile(path.join(directory, 'catalog.json'), 'utf8'));
await mkdir(directory, {recursive: true});
await mkdir(staging, {recursive: true});
const clips = [...catalogue.clips];
let completed = 0;
const failures = [];

function run(command, args) {
  return new Promise((resolve, reject) => {
    const process = spawn(command, args, {stdio: ['ignore', 'pipe', 'pipe']});
    let stdout = '', stderr = '';
    process.stdout.on('data', chunk => stdout += chunk);
    process.stderr.on('data', chunk => stderr += chunk);
    process.on('error', reject);
    process.on('close', code => code === 0 ? resolve(stdout) : reject(new Error(stderr.slice(-800))));
  });
}

async function worker() {
  while (clips.length) {
    const clip = clips.shift();
    if (!/^[A-Za-z0-9_-]{11}$/.test(clip.sourceId)) throw new Error('Invalid source ID');
    const target = path.join(directory, `${clip.sourceId}.mp4`);
    try {
      if (!(await stat(target).catch(() => null))?.size) {
        const pending = path.join(staging, `${clip.sourceId}.mp4`);
        await run('yt-dlp', [
          '--no-update', '--no-playlist', '--quiet', '--no-warnings',
          '--retries', '2', '--fragment-retries', '2',
          '-f', 'bv[vcodec^=avc1][height<=1080][ext=mp4]/b[vcodec^=avc1][height<=1080][ext=mp4]',
          '-o', pending, '--', `https://www.youtube.com/watch?v=${clip.sourceId}`,
        ]);
        const probe = JSON.parse(await run('ffprobe', ['-v', 'error', '-show_streams', '-show_format', '-of', 'json', pending]));
        const video = probe.streams.find(stream => stream.codec_type === 'video');
        if (!video || video.codec_name !== 'h264' || video.width !== 1920 || video.height !== 1080 ||
            Number(probe.format.duration) <= 0 || Number(probe.format.duration) > 90) {
          throw new Error('Expected a short 1080p H.264 clip; pending file preserved');
        }
        await rename(pending, target);
      }
      console.log(`${++completed}/${catalogue.clips.length}: ${clip.id} ready`);
    } catch (error) {
      failures.push(clip.id);
      console.error(`${clip.id}: ${error.message}`);
    }
  }
}

await Promise.all(Array.from({length: 4}, worker));
if (failures.length) {
  console.error(`Missing clips: ${failures.join(', ')}`);
  process.exitCode = 1;
}
