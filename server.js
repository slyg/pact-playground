const express = require("express");
const app = express();
const port = 3000;

/**
 * Server, supposedly a different project
 */

app
  .get("/", (req, res) => res.send({ message: "Welcome" }))
  .get("/truc", (req, res) => res.send({ ok: true }))
  .listen(port, () => console.log(`Example app listening on port ${port}`));
