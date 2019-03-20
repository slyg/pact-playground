/**
 * @jest-environment node
 */
const { getOK, getKO } = require("../api");
const { provider, port } = require("../providerMock");
const okReponse = require("./ok-response");
const notOkReponse = require("./not-ok-response");

const url = "http://localhost";

describe("The API", () => {
  beforeAll(() => provider.setup()); // Create mock provider
  afterEach(() => provider.verify());
  afterAll(() => provider.finalize());

  describe("The getOK api", () => {
    beforeAll(() => {
      provider.addInteraction(okReponse);
    });

    it("Returns a sucessful response", done => {
      getOK({ url, port })
        .then(response => {
          expect(response).toEqual("It is OK");
        })
        .then(done);
    });
  });

  describe("The getKO api", () => {
    beforeAll(() => {
      provider.addInteraction(notOkReponse);
    });

    it("Returns an errored response", done => {
      getKO({ url, port })
        .then(response => {
          expect(response).toEqual("It is not OK");
        })
        .then(done);
    });
  });
});
