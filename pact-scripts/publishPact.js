const util = require("util");
const exec = util.promisify(require("child_process").exec);
const { publishPacts } = require("@pact-foundation/pact-node");

(async () => {
  try {
    const opts = {
      tags: "test",
      consumerVersion: (await exec("git rev-parse HEAD")).stdout.trim(),
      pactFilesOrDirs: [`${process.cwd()}/pacts`],
      pactBroker: "http://localhost/"
    };
    console.log(opts);
    await publishPacts(opts);
  } catch (e) {
    console.error(e);
    throw e;
  }
})();
