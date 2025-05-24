const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Create a production build
console.log('Creating production build...');

// Build the client
console.log('Building client...');
execSync('npm run build:client', { stdio: 'inherit' });

// Build the server
console.log('Building server...');
execSync('npm run build:server', { stdio: 'inherit' });

// Copy necessary files to dist folder
const distDir = path.join(__dirname, 'dist');
if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir);
}

// Copy package.json
fs.copyFileSync(
  path.join(__dirname, 'package.json'),
  path.join(distDir, 'package.json')
);

// Create a simple production start script
const startScript = `
#!/usr/bin/env node
require('./server/index.js');
`;

fs.writeFileSync(path.join(distDir, 'start.js'), startScript);
console.log('Build completed successfully!');