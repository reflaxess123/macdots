#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const DEBUG_FILE = '/tmp/.claude_statusline_input.json';

function safe(fn, fb) { try { return fn(); } catch { return fb; } }
function sh(cmd, timeout = 2000) {
  return execSync(cmd, { encoding: 'utf8', timeout, stdio: ['ignore', 'pipe', 'ignore'] });
}

const raw = fs.readFileSync(0, 'utf8');
const input = safe(() => JSON.parse(raw), {});
safe(() => fs.writeFileSync(DEBUG_FILE, raw));

// ── 1. dir ────────────────────────────────────────────────────────────────
const cwd = input?.workspace?.current_dir || input?.cwd || '';
const dirName = cwd ? path.basename(cwd) : '';

// ── 2. git ────────────────────────────────────────────────────────────────
let gitSegment = '';
if (cwd) {
  const branch = safe(() => sh(`git -C "${cwd}" symbolic-ref --short HEAD 2>/dev/null`).trim(), '')
    || safe(() => sh(`git -C "${cwd}" rev-parse --short HEAD 2>/dev/null`).trim(), '');
  if (branch) {
    const numstat = safe(() => sh(`git -C "${cwd}" diff --numstat HEAD 2>/dev/null`), '');
    let added = 0, deleted = 0;
    for (const line of numstat.split('\n')) {
      const [a, d] = line.split('\t');
      if (/^\d+$/.test(a)) added += +a;
      if (/^\d+$/.test(d)) deleted += +d;
    }
    gitSegment = `⎇ ${branch}(+${added},-${deleted})`;
  }
}

// ── 3. model / effort / style / context ───────────────────────────────────
let model = (input?.model?.display_name || '').replace(/\s*\([^)]*\)\s*$/, '').trim();
const effort = input?.effort?.level || '';
let style = input?.output_style?.name || '';
if (style === 'default' || style === 'null') style = '';

const ctx = input?.context_window || {};
const ctxPct = ctx.used_percentage != null ? (+ctx.used_percentage).toFixed(1) : '';
const ctxTokens = (ctx.total_input_tokens || 0) + (ctx.total_output_tokens || 0);
const ctxK = ctxTokens > 0 ? (ctxTokens / 1000).toFixed(1) : '';

let modelSegment = '';
if (model) {
  modelSegment = `🤖 ${model}`;
  if (effort) modelSegment += ` ${effort}`;
  if (style) modelSegment += ` ${style}`;
  if (ctxPct && ctxK) modelSegment += ` ${ctxPct}% ${ctxK}k`;
}

// ── 4 & 5. rate limits (already in input JSON) ────────────────────────────
function humanSecs(s) {
  if (!s || s <= 0) return '--';
  const d = Math.floor(s / 86400);
  const h = Math.floor((s % 86400) / 3600);
  const m = Math.floor((s % 3600) / 60);
  return d > 0 ? `${d}d ${h}hr ${m}m` : `${h}hr ${m}m`;
}

const now = Math.floor(Date.now() / 1000);

function rlSegment(rl, prefix) {
  if (!rl || rl.used_percentage == null) return `● ${prefix}--`.trimEnd();
  const pct = (+rl.used_percentage).toFixed(1);
  const remaining = rl.resets_at ? +rl.resets_at - now : 0;
  return `● ${prefix}${pct}% ${humanSecs(remaining)}`;
}

const fiveSegment = rlSegment(input?.rate_limits?.five_hour, '5h ');
const weekSegment = rlSegment(input?.rate_limits?.seven_day, '');

// ── assemble ──────────────────────────────────────────────────────────────
const parts = [`📁 ${dirName}`];
if (gitSegment) parts.push(gitSegment);
if (modelSegment) parts.push(modelSegment);
parts.push(fiveSegment, weekSegment);
process.stdout.write(parts.join('  '));
