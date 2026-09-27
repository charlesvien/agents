#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const MAX_SHOWN = 10;

const SYNTAX = {};

function register(exts, syntax) {
  for (const ext of exts) SYNTAX[ext] = syntax;
}

register(
  ['js', 'jsx', 'mjs', 'cjs', 'ts', 'tsx', 'mts', 'cts', 'go', 'rs', 'c', 'h', 'cc', 'cpp', 'hpp'],
  { line: '//', block: true }
);
register(
  ['cs', 'java', 'kt', 'kts', 'scala', 'swift', 'dart', 'php', 'scss', 'less', 'proto', 'jsonc'],
  { line: '//', block: true }
);
register(['vue', 'svelte', 'astro'], { line: '//', block: true, html: true });
register(['py'], { line: '#', docstring: true });
register(
  ['rb', 'sh', 'bash', 'zsh', 'fish', 'yml', 'yaml', 'toml', 'tf', 'hcl', 'nix', 'graphql'],
  { line: '#' }
);
register(['r', 'pl', 'ex', 'exs', 'dockerfile', 'makefile', 'cmake', 'env'], { line: '#' });
register(['sql'], { line: '--', block: true });
register(['lua', 'hs', 'elm'], { line: '--' });
register(['css'], { block: true });
register(['html', 'htm', 'xml', 'svg'], { html: true });

const DIRECTIVES = [
  'eslint-',
  'biome-ignore',
  '@ts-',
  'prettier-ignore',
  'istanbul ignore',
  'c8 ignore',
  'v8 ignore',
  'noqa',
  'type: ignore',
  'pyright:',
  'mypy:',
  'pylint:',
  'ruff:',
  'fmt:',
  'rubocop:',
  'nolint',
  'nosec',
  'shellcheck',
  'go:build',
  'go:generate',
  'go:embed',
  '<reference',
  'frozen_string_literal',
  '-*-',
  '@vitest-environment',
  '@jest-environment',
  'syntax=',
  'swiftlint:',
  'SPDX-License-Identifier',
  'webpackChunkName',
  '@__PURE__',
  '@refresh',
  'deno-lint-ignore',
  'stylelint-',
  'cspell:',
  '@license',
  'yaml-language-server',
  '@jsxImportSource',
  '@vite-ignore',
  'NOSONAR',
  '@generated',
];

function syntaxFor(file) {
  const base = path.basename(file).toLowerCase();
  return SYNTAX[path.extname(base).slice(1) || base.replace(/^\./, '')];
}

function linesNotIn(before, after) {
  const existing = new Set((before || '').split('\n'));
  return (after || '').split('\n').filter((line) => !existing.has(line));
}

function addedLines(input, response) {
  const patch = response && response.structuredPatch;
  if (Array.isArray(patch) && patch.length > 0) {
    return patch
      .flatMap((hunk) => hunk.lines || [])
      .filter((line) => line.startsWith('+'))
      .map((line) => line.slice(1));
  }
  if (typeof input.content === 'string') {
    return linesNotIn(response && response.originalFile, input.content);
  }
  const edits = Array.isArray(input.edits) ? input.edits : [input];
  return edits.flatMap((edit) => linesNotIn(edit.old_string, edit.new_string));
}

function isComment(line, syntax) {
  const text = line.trim();
  if (!text) return false;
  if (syntax.block && /^(\{\s*)?\/\*|^\*(\s|\/|$)/.test(text)) return true;
  if (syntax.html && text.startsWith('<!--')) return true;
  if (syntax.docstring && /^[rRbBuU]?("""|''')/.test(text)) return true;
  if (!syntax.line) return false;
  return (
    text.startsWith(syntax.line) || new RegExp(`\\S\\s+${syntax.line}(\\s|$)`).test(text)
  );
}

function isDirective(line) {
  return line.trim().startsWith('#!') || DIRECTIVES.some((directive) => line.includes(directive));
}

function main() {
  let payload;
  try {
    payload = JSON.parse(fs.readFileSync(0, 'utf8'));
  } catch {
    process.exit(0);
  }

  const input = payload.tool_input || {};
  const file = input.file_path || '';
  const syntax = syntaxFor(file);
  if (!syntax) process.exit(0);

  const comments = addedLines(input, payload.tool_response)
    .filter((line) => isComment(line, syntax) && !isDirective(line))
    .map((line) => line.trim());
  if (comments.length === 0) process.exit(0);

  const shown = comments.slice(0, MAX_SHOWN).map((line) => `  ${line}`);
  if (comments.length > MAX_SHOWN) shown.push(`  ...and ${comments.length - MAX_SHOWN} more`);

  const reason = [
    `[NoComments] You added ${comments.length} comment line(s) to ${file}:`,
    ...shown,
    'The user does not allow code comments. Delete these now.',
    'Keep one only if it explains a why the code cannot express, and name it in your reply.',
    'Ignore lines that already existed and were only moved.',
  ].join('\n');

  process.stdout.write(JSON.stringify({ decision: 'block', reason }));
  process.exit(0);
}

main();
