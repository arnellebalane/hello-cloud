const server = require('server');
const cors = require('cors');
const morgan = require('morgan');
const { get } = server.router;
const { json } = server.reply;
const { modern } = server.utils;
const pkg = require('./package.json');

const {
  PORT = 3000,
  CORS_ORIGINS = false,
} = process.env;

const options = {
  port: PORT,
  security: {
    csrf: false,
  },
};

server(
  options,

  modern(cors({
    origin: CORS_ORIGINS ? [CORS_ORIGINS] : CORS_ORIGINS,
  })),
  modern(morgan('tiny')),

  get('/', () => json({
    name: pkg.name,
    version: pkg.version,
  })),
).then(ctx => {
  console.log('PORT:', PORT);
  console.log('CORS_ORIGINS:', CORS_ORIGINS);
});



// Graceful shutdown
const signals = {
  SIGHUP: 1,
  SIGINT: 2,
  SIGTERM: 15
};

const shutdown = (signal, value) => {
  throw new Error(`Server stopped by ${signal} with value ${value}`);
};

Object.keys(signals).forEach(signal => {
  process.on(signal, () => shutdown(signal, signals[signal]));
});
