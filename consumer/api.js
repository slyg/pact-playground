const axios = require("axios");

/**
 * Very simple api
 */

exports.getOK = async ({ url, port }) => {
  const { data } = await axios.request({
    method: "GET",
    baseURL: `${url}:${port}`,
    url: "/ok",
    headers: { Accept: "application/json" }
  });

  return `It is ${data.message}`;
};

exports.getKO = async ({ url, port }) => {
  try {
    await axios.request({
      method: "GET",
      baseURL: `${url}:${port}`,
      url: "/ko",
      headers: { Accept: "application/json" }
    });
  } catch (e) {
    return "It is not OK";
  }
};
