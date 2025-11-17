#!/usr/bin/env node
/*
 Simple CORS proxy for Flutter Web dev.
 - Proxies all requests to the configured TARGET (Railway backend)
 - Adds permissive CORS headers for localhost origins
 - Handles OPTIONS preflight with 204

Usage:
  node scripts/cors-proxy.js [port]
Defaults:
  port: 8787
  target: https://backend-production-cc13.up.railway.app
*/

const http = require('http');
const https = require('https');
const { URL } = require('url');

const PORT = Number(process.argv[2]) || 8787;
const TARGET = process.env.TARGET || 'https://backend-production-cc13.up.railway.app';
const targetUrl = new URL(TARGET);

function setCors(res, origin) {
  res.setHeader('Access-Control-Allow-Origin', origin || '*');
  res.setHeader('Vary', 'Origin');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
}

const server = http.createServer((req, res) => {
  const origin = req.headers.origin || '*';

  if (req.method === 'OPTIONS') {
    setCors(res, origin);
    res.statusCode = 204;
    res.end();
    return;
  }

  const path = req.url.startsWith('/') ? req.url : `/${req.url}`;
  const outUrl = new URL(path, targetUrl);

  const headers = { ...req.headers };
  // Host header should match target
  headers.host = targetUrl.host;
  // Remove origin header to avoid CORS issues on target server
  // Backend will treat this as a non-browser request (like mobile app)
  delete headers.origin;
  delete headers.referer;

  const opts = {
    protocol: targetUrl.protocol,
    hostname: targetUrl.hostname,
    port: targetUrl.port || (targetUrl.protocol === 'https:' ? 443 : 80),
    method: req.method,
    path: outUrl.pathname + (outUrl.search || ''),
    headers,
  };

  const client = targetUrl.protocol === 'https:' ? https : http;

  const proxyReq = client.request(opts, (proxyRes) => {
    setCors(res, origin);
    // Pipe status and headers
    res.writeHead(proxyRes.statusCode || 502, proxyRes.headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    setCors(res, origin);
    res.statusCode = 502;
    res.end(`Proxy error: ${err.message}`);
  });

  req.pipe(proxyReq);
});

server.listen(PORT, () => {
  console.log(`CORS proxy listening on http://localhost:${PORT} -> ${TARGET}`);
});
