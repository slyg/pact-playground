const express = require("express");
const app = express();
const port = 3000;

/**
 * Server, supposedly a different project
 */

app
  .get("/", (req, res) => res.send({ message: "Welcome" }))
  .get("/ok", (req, res) => res.send({ message: "OK" }))
  .get("/ko", (req, res) =>
    res.status(500).send({ error: "No no no no nooooohhh !" })
  )
  .listen(port, () => console.log(`Example app listening on port ${port}`));
