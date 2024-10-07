// Example express application adding the parse-server module to expose Parse
// compatible API routes.

import express from 'express';
import { ParseServer } from 'parse-server';
import path from 'path';
const __dirname = path.resolve();
import http from 'http';
import ParseDashboard from 'parse-dashboard';
import FSFilesAdapter from '@parse/fs-files-adapter';
import cors from 'cors';
import dotenv from 'dotenv';
import { Server } from "socket.io";
import os from 'os';
import { UnisenderMailAdapter } from './unisender.js';

dotenv.config();

var clientKey = 'jnjcM&kiQrMSfx#gLixq&#kCri4&3kYXLTJoABSC';
var masterKey = '?8t8FgG69oRF7PTEn5qQzG#x76Nn@JdzNGT!s$GT';
var adminPassword = "F?3At9jLRrfQ8kJt9TQkY@TXg@8gAKGdMh?APseK";

var dashboard = new ParseDashboard({
 "apps": [
   {
     "serverURL": "http://82.146.47.140:1339/parse/api/",
     "appId": "application",
     "masterKey": masterKey,
     "appName": "application"
   }
 ],
 "users": [
   {
    "user": "admin",
    "pass": adminPassword
   }
 ]
}, { allowInsecureHTTP: true });

var fsAdapter = new FSFilesAdapter({
  "filesSubDirectory": "files"
});

export const config = {
  databaseURI: 'mongodb://localhost:27017/db',
  cloud: __dirname + '/cloud/main.js',
  appId: 'application',
  masterKeyIps: ['0.0.0.0/0', '::/0'],
  masterKey: masterKey,
  clientKey: clientKey,
  serverURL: process.env.SERVER_URL || 'http://82.146.47.140:1339/parse/api',
  liveQuery: {
    classNames: ["Some"],
  },
  allowClientClassCreation: true,
  expireInactiveSessions: false,
  encodeParseObjectInCloudFunction: true,
  directAccess: true,
  logLevel: "error",
  fileUpload: {
    enableForPublic: true,
    enableForAnonymousUser: true,
    enableForAuthenticatedUser: true
  },
  filesAdapter: fsAdapter,
  appName: 'application',
  publicServerURL: 'http://82.146.47.140:1339/parse/api',
  verifyUserEmails: true,
  emailAdapter: {
    module: UnisenderMailAdapter,
    options: {
      //"6kbhh4pmrzs3f7e8rh7i8ugzs31ig47cop76i6de",//
      apiKey: "6k411zoazdano1qqxrturuunaf8t196wffidrrby",
      senderName: 'KMPOInvent',
      senderEmail: 'new@kfv900.ru'
    }
  }
};

export const app = express();

app.set('trust proxy', true);

app.use(cors());

const mountPath = '/parse/api';
const server = new ParseServer(config);
await server.start();
app.use(mountPath, server.app);
  
app.use('/dashboard', dashboard);
app.use('/files', express.static(path.join(__dirname, '/files/files')));

const port = 1339;
const httpServer = http.createServer(app, (req, res) => {
  res.end();
});
httpServer.listen(port, function () {
    console.log('parse-server running on port ' + port + '.');
});
// This will enable the Live Query real-time server
await ParseServer.createLiveQueryServer(httpServer);

const statApp = express();
const statServer = http.createServer(statApp);
const statIo = new Server(statServer);
statApp.use('/', express.static(path.join(__dirname, '/web_stat')));

statIo.on('connection', (socket) => {
  console.log('New client connected');

  const sendStats = () => {
    const stats = {
      freeMemory: os.freemem(),
      totalMemory: os.totalmem(),
      loadAverage: os.loadavg(),
      uptime: os.uptime(),
    };
    socket.emit('stats', stats);
  };

  sendStats();
  const interval = setInterval(sendStats, 1000);

  socket.on('disconnect', () => {
    clearInterval(interval);
    console.log('Client disconnected');
  });
});

statServer.listen(3000, () => {
  console.log('Stat server is running on port 3000');
});
