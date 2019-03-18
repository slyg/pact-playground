const path = require("path");
const Verifier = require("@pact-foundation/pact").Verifier;

const PROVIDER_NAME = "MyProvider";
const PROVIDER_BASE_URL = "http://localhost:3000";

/**
 * Verify that the provider meets all consumer expectations
 */

describe("Pact Verification", () => {
  it("should validate the expectations of Our Little Consumer", () => {
    let opts = {
      provider: PROVIDER_NAME,
      providerBaseUrl: PROVIDER_BASE_URL,
      pactUrls: [
        path.resolve(process.cwd(), "pacts/myconsumer-myprovider.json")
      ]
    };

    return new Verifier().verifyProvider(opts);
  });
});
