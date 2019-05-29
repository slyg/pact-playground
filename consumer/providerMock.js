const path = require("path");
const { Pact } = require("@pact-foundation/pact");

/**
 * Pact backed mock sever
 */

const MOCK_SERVER_PORT = 8989;

const provider = new Pact({
  consumer: "pactConsumer_frontend",
  provider: "pactProvider_backend",
  port: MOCK_SERVER_PORT,
  log: path.resolve(process.cwd(), "logs", "mockserver-integration.log"),
  logLevel: "error",
  dir: path.resolve(process.cwd(), "pacts"),
  pactfileWriteMode: "update",
  spec: 2,
  cors: true
});

module.exports = { port: MOCK_SERVER_PORT, provider };
