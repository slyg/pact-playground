/**
 * @jest-environment node
 */
const { getOK, getKO } = require("../api");
const { provider, port } = require("../providerMock");

const url = "http://localhost";

describe("The API", () => {
  beforeAll(() => provider.setup()); // Create mock provider
  afterEach(() => provider.verify());
  afterAll(() => provider.finalize());

  describe("The getOK api", () => {
    const EXPECTED_BODY = { message: "OK" };

    beforeEach(() => {
      provider.addInteraction({
        uponReceiving: "a request",
        withRequest: {
          method: "GET",
          path: "/ok",
          headers: {
            Accept: "application/json"
          }
        },
        willRespondWith: {
          status: 200,
          headers: {
            "Content-Type": "application/json; charset=utf-8"
          },
          body: EXPECTED_BODY
        }
      });
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
    const EXPECTED_BODY = { error: "No no no no nooooohhh !" };

    beforeEach(() => {
      provider.addInteraction({
        uponReceiving: "another request",
        withRequest: {
          method: "GET",
          path: "/ko",
          headers: {
            Accept: "application/json"
          }
        },
        willRespondWith: {
          status: 500,
          headers: {
            "Content-Type": "application/json; charset=utf-8"
          },
          body: EXPECTED_BODY
        }
      });
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
