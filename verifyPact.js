const { Verifier } = require("@pact-foundation/pact-node");
const util = require("util");
const exec = util.promisify(require("child_process").exec);

(async () => {
  try {
    const opts = {
      tags: "test",
      consumerVersion: (await exec("git rev-parse HEAD")).stdout.trim(),
      pactFilesOrDirs: [`${process.cwd()}/pacts`],
      pactBroker: "http://localhost/"
    };
    console.log(opts);
    await new Verifier().verifyProvider(opts);
  } catch (e) {
    console.error(e);
    throw e;
  }
})();
