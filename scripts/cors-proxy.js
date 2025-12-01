#!/usr/bin/env node
/*
 Simple CORS proxy for Flutter Web dev.
 - Proxies requests to multiple targets based on path
 - Adds permissive CORS headers for localhost origins
 - Handles OPTIONS preflight with 204

Usage:
  node scripts/cors-proxy.js [port]
Defaults:
  port: 8787
  Primary target: https://backend-production-cc13.up.railway.app
  Gorse target: http://mf_recommender.digilabdte.com
*/

const http = require('http');
const https = require('https');
const { URL } = require('url');

const PORT = Number(process.argv[2]) || 8787;
const BACKEND_TARGET = 'https://backend-production-cc13.up.railway.app';
const GORSE_TARGET = 'http://mf_recommender.digilabdte.com';

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

  // Determine target based on path
  let targetUrl;
  if (req.url.startsWith('/gorse/')) {
    // Route /gorse/* to Gorse server
    targetUrl = new URL(req.url.substring(6), GORSE_TARGET); // Remove /gorse prefix
    console.log(`[Gorse] ${req.method} ${targetUrl.toString()}`);
  } else {
    // Route everything else to backend
    targetUrl = new URL(req.url, BACKEND_TARGET);
    console.log(`[Backend] ${req.method} ${targetUrl.toString()}`);
  }

  const headers = { ...req.headers };
  headers.host = targetUrl.host;
  delete headers.origin;
  delete headers.referer;

  const opts = {
    protocol: targetUrl.protocol,
    hostname: targetUrl.hostname,
    port: targetUrl.port || (targetUrl.protocol === 'https:' ? 443 : 80),
    method: req.method,
    path: targetUrl.pathname + (targetUrl.search || ''),
    headers,
  };

  const client = targetUrl.protocol === 'https:' ? https : http;

  const proxyReq = client.request(opts, (proxyRes) => {
    setCors(res, origin);
    console.log(`[Response] ${proxyRes.statusCode} from ${targetUrl.host}`);
    res.writeHead(proxyRes.statusCode || 502, proxyRes.headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    setCors(res, origin);
    console.error(`[Error] ${err.message} for ${targetUrl.toString()}`);
    res.statusCode = 502;
    res.end(`Proxy error: ${err.message}`);
  });

  req.pipe(proxyReq);
});

server.listen(PORT, () => {
  console.log(`CORS proxy listening on http://localhost:${PORT}`);
  console.log(`  - Backend: ${BACKEND_TARGET}`);
  console.log(`  - Gorse: /gorse/* -> ${GORSE_TARGET}`);
});
