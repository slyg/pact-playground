/**
 * @jest-environment node
 */
const { getTruc } = require("../api");
const { provider, port } = require("../providerMock");

const url = "http://localhost";

describe("The API", () => {
  beforeAll(() => provider.setup()); // Create mock provider
  afterEach(() => provider.verify());
  afterAll(() => provider.finalize());

  describe("The getTruc api", () => {
    const EXPECTED_BODY = { ok: true };

    beforeEach(() => {
      provider.addInteraction({
        uponReceiving: "a request",
        withRequest: {
          method: "GET",
          path: "/truc",
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
      getTruc({ url, port })
        .then(response => {
          expect(response.headers["content-type"]).toEqual(
            "application/json; charset=utf-8"
          );
          expect(response.data).toEqual(EXPECTED_BODY);
          expect(response.status).toEqual(200);
        })
        .then(done);
    });
  });
});
