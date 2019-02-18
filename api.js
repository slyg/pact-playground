const axios = require("axios");

/**
 * Very simple api
 */

exports.getTruc = ({ url, port }) =>
  axios.request({
    method: "GET",
    baseURL: `${url}:${port}`,
    url: "/truc",
    headers: { Accept: "application/json" }
  });
